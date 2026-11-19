#!/usr/bin/env python3
"""Recount how ECMA-262 17th edition splits the Math functions.

Backs the post's footnote on the split: of the 37 function properties of
`Math` in section 21.3.2, 22 are implementation-approximated, 1 is
implementation-defined, and 14 are exact.

Usage:
    python3 -I spec/recount-split.py

Environment:
    SPEC_CACHE_DIR   where the downloaded edition is kept, outside the repo.
                     Default: <system temp dir>/whose-maths-spec-cache
    SPEC_OUT_DIR     where the outputs are written.
                     Default: the directory this script is in.

Downloads https://262.ecma-international.org/17.0/ (a fixed edition), checks
its sha256 against EXPECTED_SHA256 and stops with an error if it differs, then
classifies each function by the rule below. Standard library only. macOS or
Linux.

The rule, applied to each clause "Math.<name>" in 21.3.2, using only the
specification's own text:

  implementation-approximated
      The clause's own text uses the term "implementation-approximated", or
      its steps call an abstract operation (an xref with an `aoid`) whose own
      text uses it. Only `Math.pow` takes the second route: its one step is
      Number::exponentiate, which "returns an implementation-approximated
      value".
  implementation-defined
      The clause's own text uses the term "implementation-defined".
  exact
      Neither, in the clause or in any abstract operation it calls.

"Own text" means the clause up to its first nested clause, so a term in a
sibling or in a clause the function merely links to (such as the Number type)
doesn't count. As a cross-check, the Note that opens 21.3.2 lists the 23
functions whose behavior "is not precisely specified"; that list must equal
the approximated and implementation-defined sets together.
"""

import datetime
import hashlib
import html
import os
import platform
import re
import sys
import tempfile
import urllib.request

EDITION_URL = "https://262.ecma-international.org/17.0/"
ANCHOR_BASE = "https://262.ecma-international.org/17.0/index.html#"
EXPECTED_SHA256 = "5df49e088c2b5c7a3dfd4a330414b92897fb4535cb62fc5936cad101a6c2304a"
EXPECTED_SPLIT = {"implementation-approximated": 22, "implementation-defined": 1, "exact": 14}
SECTION_ID = "sec-function-properties-of-the-math-object"
TERMS = ("implementation-approximated", "implementation-defined")
SCRIPT = "spec/recount-split.py"


def fetch(cache_dir):
    os.makedirs(cache_dir, exist_ok=True)
    path = os.path.join(cache_dir, "ecma-262-17.0.html")
    if not os.path.exists(path):
        req = urllib.request.Request(EDITION_URL, headers={"User-Agent": "whose-maths-spec/1.0"})
        with urllib.request.urlopen(req, timeout=120) as r, open(path, "wb") as f:
            f.write(r.read())
    data = open(path, "rb").read()
    digest = hashlib.sha256(data).hexdigest()
    if digest != EXPECTED_SHA256:
        sys.exit(
            "sha256 mismatch for %s\n  expected %s\n  got      %s\n"
            "The 17th edition at %s was expected to be fixed. Delete %s and retry, "
            "or, if the file really changed, say so in the README before updating the hash."
            % (EDITION_URL, EXPECTED_SHA256, digest, EDITION_URL, path)
        )
    mtime = datetime.datetime.fromtimestamp(os.path.getmtime(path), datetime.timezone.utc)
    return data.decode("utf-8"), digest, mtime.strftime("%Y-%m-%dT%H:%M:%SZ")


def text_of(fragment, sep=" "):
    return re.sub(r"\s+", " ", html.unescape(re.sub(r"<[^>]+>", sep, fragment))).replace("\u00a0", " ").strip()


def own_clauses(page):
    """Map clause id -> HTML of the clause up to its first nested clause."""
    out = {}
    for m in re.finditer(r'<emu-clause id="([^"]+)"', page):
        nxt = page.find("<emu-clause", m.end())
        end = page.find("</emu-clause>", m.end())
        stops = [x for x in (nxt, end) if x > 0]
        out[m.group(1)] = page[m.start(): min(stops)]
    return out


def deciding_text(clause_html):
    """Where a clause uses one of TERMS, and the text there: a paragraph
    sentence, or else the algorithm step (a leaf list item) that uses it."""
    for p in re.findall(r"<p>(.*?)</p>", clause_html, re.S):
        t = text_of(p, "")
        for s in re.split(r"(?<=[.!?])\s+(?=[A-Z0-9])", t):
            if any(term in s for term in TERMS):
                return "sentence", s
    for lm in re.finditer(r"<li>((?:(?!<li>).)*?)</li>", clause_html, re.S):
        li = lm.group(1)
        if any(term in li for term in TERMS):
            m = re.search(r'class="list-marker">\s*([^<]*?)\s*</span>', li)
            step = m.group(1).rstrip(".") if m else "?"
            if not step.isdigit():  # a nested item such as "a": name its top-level step too
                tops = re.findall(r'class="list-marker">(\d+)\. </span>', clause_html[: lm.start()])
                step = "%s.%s" % (tops[-1], step) if tops else step
            body = re.sub(r'<span aria-hidden="true" class="list-marker">.*?</span>', "", li, flags=re.S)
            return "step %s" % step, text_of(body, "")
    return "", ""


def step_number(clause_html, aoid):
    """The step number of the first list item that calls `aoid`."""
    for li in re.findall(r"<li>(.*?)</li>", clause_html, re.S):
        if 'aoid="%s"' % aoid in li:
            m = re.search(r'class="list-marker">\s*([^<]*?)\s*</span>', li)
            return m.group(1) if m else "?"
    return "?"


def classify(clauses, cid):
    body = clauses[cid]
    approx = "implementation-approximated" in body
    defined = "implementation-defined" in body
    if approx or defined:
        cat = "implementation-approximated" if approx else "implementation-defined"
        where, text = deciding_text(body)
        return cat, "this clause, %s" % where, text
    # abstract operations this clause calls whose own text uses a term
    for aoid, href in re.findall(r'<emu-xref aoid="([^"]+)"[^>]*><a href="#([^"]+)"', body):
        target = clauses.get(href)
        if target and any(term in target for term in TERMS):
            cat = "implementation-approximated" if "implementation-approximated" in target else "implementation-defined"
            where, text = deciding_text(target)
            return cat, "%s (called at step %s), %s" % (aoid, step_number(body, aoid).rstrip("."), where), text
    return "exact", "no term in this clause or in the operations it calls", ""


def main():
    cache_dir = os.environ.get("SPEC_CACHE_DIR") or os.path.join(tempfile.gettempdir(), "whose-maths-spec-cache")
    out_dir = os.environ.get("SPEC_OUT_DIR") or os.path.dirname(os.path.abspath(__file__))
    page, digest, downloaded = fetch(cache_dir)
    clauses = own_clauses(page)

    start = page.find('<emu-clause id="%s"' % SECTION_ID)
    if start < 0:
        sys.exit("21.3.2 not found")
    section = page[start:]
    # the section's functions, in document order: Math.<name> clauses, until the next non-Math clause at this level
    funcs = []
    for m in re.finditer(r'<emu-clause id="(sec-math\.[^"]+)"[^>]*>\s*<h1><span class="secnum">([^<]+)</span>\s*Math\.(\w+)', section):
        funcs.append((m.group(3), m.group(1), m.group(2)))
    # keep only the run that is contiguous in the section (21.3.2.N)
    funcs = [f for f in funcs if f[2].startswith("21.3.2.")]

    rows = []
    for name, cid, num in funcs:
        cat, where, sentence = classify(clauses, cid)
        rows.append((name, num, ANCHOR_BASE + cid, cat, where, sentence))

    counts = {k: sum(1 for r in rows if r[3] == k) for k in EXPECTED_SPLIT}

    # cross-check against the list in the Note that opens 21.3.2
    note = re.search(r"<emu-note>(.*?)</emu-note>", section, re.S).group(1)
    note = note.split("is not precisely specified")[0]  # the function list; a later <code> names fdlibm
    listed = set(re.findall(r"<code>(\w+)</code>", note))
    decided = {r[0] for r in rows if r[3] != "exact"}
    note_ok = listed == decided

    now = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    header = [
        "# engine:   ECMA-262 17th edition (ES2026), HTML at %s, sha256 %s" % (EDITION_URL, digest),
        "# platform: %s, %s, Python %s" % (platform.platform(), platform.machine(), platform.python_version()),
        "# obtained: downloaded from %s on %s (urllib); sha256 checked against the value in the script" % (EDITION_URL, downloaded),
        "# date:     %s" % now,
        "# script:   %s" % SCRIPT,
    ]

    tsv = header + [
        "function\tclause\tlink\tcategory\tdecided_by\ttext",
    ]
    for name, num, link, cat, where, sentence in rows:
        tsv.append("Math.%s\t%s\t%s\t%s\t%s\t%s" % (name, num, link, cat, where, sentence))
    with open(os.path.join(out_dir, "split.tsv"), "w", encoding="utf-8") as f:
        f.write("\n".join(tsv) + "\n")

    res = header + [
        "",
        "function properties of Math in 21.3.2: %d" % len(rows),
        "implementation-approximated: %d" % counts["implementation-approximated"],
        "implementation-defined: %d" % counts["implementation-defined"],
        "exact: %d" % counts["exact"],
        "",
        "implementation-approximated: " + ", ".join(r[0] for r in rows if r[3] == "implementation-approximated"),
        "implementation-defined: " + ", ".join(r[0] for r in rows if r[3] == "implementation-defined"),
        "exact: " + ", ".join(r[0] for r in rows if r[3] == "exact"),
        "",
        "functions named in the Note that opens 21.3.2 (%d) equal the non-exact set (%d): %s"
        % (len(listed), len(decided), "yes" if note_ok else "NO, differences: %s" % sorted(listed ^ decided)),
        "split the post states: %s" % ", ".join("%d %s" % (v, k) for k, v in EXPECTED_SPLIT.items()),
        "recount matches the post: %s" % ("yes" if counts == EXPECTED_SPLIT and len(rows) == 37 else "NO"),
    ]
    with open(os.path.join(out_dir, "split.results.txt"), "w", encoding="utf-8") as f:
        f.write("\n".join(res) + "\n")
    print("\n".join(res[5:]))
    if counts != EXPECTED_SPLIT or len(rows) != 37 or not note_ok:
        sys.exit("recount does not match the expected split; see split.results.txt")


if __name__ == "__main__":
    main()
