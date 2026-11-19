#!/usr/bin/env python3
"""Extract how ECMA-262 defines "implementation-approximated" and "implementation-defined".

Backs the post's footnote on the two terms: the 17th edition's definitions in
4.4.1, 4.4.2, and 4.2 (including the example sentence naming Math.exp and the
sentence saying the specification makes no recommendations for
implementation-defined facilities), and that the term first appears in the
12th edition (ES2021), at 4.4.1.

Usage:
    python3 -I spec/extract-terms.py

Environment:
    SPEC_CACHE_DIR   where the downloaded editions are kept, outside the repo.
                     Default: <system temp dir>/whose-maths-spec-cache
    SPEC_OUT_DIR     where the output is written.
                     Default: the directory this script is in.

Downloads the 11th, 12th, and 17th editions from 262.ecma-international.org,
checks each file's sha256 (stopping with an error if one differs), and writes
the quoted text and counts to terms.results.txt. Each expected sentence must
be found exactly as the post quotes it, or the script stops with an error.
Standard library only. macOS or Linux.
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

SCRIPT = "spec/extract-terms.py"
BASE = "https://262.ecma-international.org/"
EDITIONS = {
    "11.0": "e9797ccca974ee27ed1d7be1bd20d02bad82b30d506c6f50fae147fe2498a99c",
    "12.0": "6728f494a385e66fad94d4f44a7677c7c09439430a3c2f673e88ea5f6ec68f0a",
    "17.0": "5df49e088c2b5c7a3dfd4a330414b92897fb4535cb62fc5936cad101a6c2304a",
}
EXAMPLE = "Some mathematical operations, such as Math.exp, are implementation-approximated."
NO_RECS = "This specification does not make any recommendations for particular behaviours"
IDEAL = "defined in whole or in part by an external source but has a recommended, ideal behaviour in this specification"
STRIVE = "they are encouraged to strive to approximate the ideal"


def fetch(cache_dir, version):
    os.makedirs(cache_dir, exist_ok=True)
    path = os.path.join(cache_dir, "ecma-262-%s.html" % version)
    if not os.path.exists(path):
        req = urllib.request.Request(BASE + version + "/", headers={"User-Agent": "whose-maths-spec/1.0"})
        with urllib.request.urlopen(req, timeout=180) as r, open(path, "wb") as f:
            f.write(r.read())
    page = open(path, "rb").read()
    digest = hashlib.sha256(page).hexdigest()
    if digest != EDITIONS[version]:
        sys.exit("sha256 mismatch for %s%s/\n  expected %s\n  got      %s\nDelete %s and retry; if the file really changed, say so in the README before updating the hash."
                 % (BASE, version, EDITIONS[version], digest, path))
    return page.decode("utf-8")


def text_of(fragment):
    return re.sub(r"\s+", " ", html.unescape(re.sub(r"<[^>]+>", "", fragment))).replace(" ", " ").strip()


def own_clause(page, cid):
    """(section number, title, HTML up to the first nested clause) of clause `cid`."""
    start = page.find('<emu-clause id="%s"' % cid)
    if start < 0:
        sys.exit("clause %s not found" % cid)
    nxt = page.find("<emu-clause", start + 10)
    end = page.find("</emu-clause>", start)
    body = page[start: min(x for x in (nxt, end) if x > 0)]
    h1 = re.search(r'<h1[^>]*>\s*<span class="secnum">([^<]*)</span>(.*?)</h1>', body, re.S)
    return h1.group(1).strip(), text_of(h1.group(2)), body


def main():
    cache_dir = os.environ.get("SPEC_CACHE_DIR") or os.path.join(tempfile.gettempdir(), "whose-maths-spec-cache")
    out_dir = os.environ.get("SPEC_OUT_DIR") or os.path.dirname(os.path.abspath(__file__))
    pages = {v: fetch(cache_dir, v) for v in EDITIONS}
    p17, p12, p11 = pages["17.0"], pages["12.0"], pages["11.0"]

    lines = []
    problems = []

    # 17th edition, 4.2 Hosts and Implementations
    num, title, body = own_clause(p17, "sec-hosts-and-implementations")
    lines.append("17th edition, %s %s: %sindex.html#sec-hosts-and-implementations" % (num, title, BASE + "17.0/"))
    paras = [text_of(p) for p in re.findall(r"<p>(.*?)</p>", body, re.S)]
    for para in paras:
        if "implementation-defined facility is one" in para or "implementation-approximated facility is one" in para:
            lines.append("  " + para)
    if not any(EXAMPLE in p for p in paras):
        problems.append("example sentence not found in 4.2")
    lines.append("  example sentence found as quoted: %s" % ("yes" if any(EXAMPLE in p for p in paras) else "NO"))
    lines.append("  sentence on implementation-defined found as quoted: %s" % ("yes" if any(NO_RECS in p for p in paras) else "NO"))
    lines.append("  'strive' wording found as quoted: %s" % ("yes" if any(STRIVE in p for p in paras) else "NO"))
    if not any(NO_RECS in p for p in paras):
        problems.append("no-recommendations sentence not found in 4.2")
    lines.append("")

    # 17th edition, 4.4.1 and 4.4.2; 12th edition, 4.4.1
    for label, page, cid in (
        ("17th edition", p17, "sec-terms-and-definitions-implementation-approximated"),
        ("17th edition", p17, "sec-terms-and-definitions-implementation-defined"),
        ("12th edition", p12, "sec-terms-and-definitions-implementation-approximated"),
    ):
        num, title, body = own_clause(page, cid)
        ver = "17.0/index.html" if label.startswith("17") else "12.0/"
        lines.append("%s, %s %s: %s%s#%s" % (label, num, title, BASE, ver, cid))
        lines.append("  " + text_of(body.split("</h1>", 1)[1]))
        if cid.endswith("approximated") and IDEAL not in text_of(body):
            problems.append("%s 4.4.1 does not contain the quoted ideal-behaviour wording" % label)
        lines.append("")

    n11, n12, n17 = (p.count("implementation-approximated") for p in (p11, p12, p17))
    lines.append("occurrences of the string 'implementation-approximated' in the whole page:")
    lines.append("  11th edition (ES2020): %d" % n11)
    lines.append("  12th edition (ES2021): %d" % n12)
    lines.append("  17th edition (ES2026): %d" % n17)
    first_ok = n11 == 0 and n12 > 0
    lines.append("absent from the 11th edition and present in the 12th: %s" % ("yes" if first_ok else "NO"))
    if not first_ok:
        problems.append("term first-appearance check failed")

    now = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    header = [
        "# engine:   ECMA-262 11th, 12th, and 17th editions (HTML, %s)" % BASE,
        "# platform: %s, %s, Python %s" % (platform.platform(), platform.machine(), platform.python_version()),
        "# obtained: downloaded from %s with urllib, a cached download reused; sha256 checked against the table in the script (11.0 %s, 12.0 %s, 17.0 %s)"
        % (BASE, EDITIONS["11.0"][:12], EDITIONS["12.0"][:12], EDITIONS["17.0"][:12]),
        "# date:     %s" % now,
        "# script:   %s" % SCRIPT,
        "",
    ]
    out = "\n".join(header + lines) + "\n"
    with open(os.path.join(out_dir, "terms.results.txt"), "w", encoding="utf-8") as f:
        f.write(out)
    print("\n".join(lines))
    if problems:
        sys.exit("problems:\n  " + "\n  ".join(problems))


if __name__ == "__main__":
    main()
