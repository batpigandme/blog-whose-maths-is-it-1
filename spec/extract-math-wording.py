#!/usr/bin/env python3
"""Extract the wording that leaves some Math functions open, edition by edition.

Backs the post's footnote on the 1st edition's wording: ten functions left
open "so that an implementor should be able to use the same mathematical
library for ECMAScript on a given hardware platform that is available to C
programmers on that platform", fdlibm recommended, and the same sentence kept
in the 17th edition with the spelling "implementer".

Usage:
    python3 -I spec/extract-math-wording.py

Environment:
    SPEC_CACHE_DIR   where the downloaded editions are kept, outside the repo.
                     Default: <system temp dir>/whose-maths-spec-cache
    SPEC_OUT_DIR     where the output is written.
                     Default: the directory this script is in.

Downloads the 1st, 2nd, 3rd, 5th, and 5.1 editions (PDF, from Ecma) and the
17th (HTML, from 262.ecma-international.org), checks each file's sha256
(stopping with an error if one differs), and writes to math-wording.results.txt
the opening text of the Function Properties of the Math Object clause (15.8.2
in the PDFs, 21.3.2 in the 17th edition): the sentence naming the functions
whose behavior "is not precisely specified", the sentence about the same
mathematical library, and the sentence recommending fdlibm, each as the
edition prints it, with the count of functions named and the spelling used.
Needs poppler's `pdftotext` on PATH. Standard library otherwise. macOS or
Linux.
"""

import datetime
import hashlib
import html
import os
import platform
import re
import subprocess
import sys
import tempfile
import urllib.request

SCRIPT = "spec/extract-math-wording.py"
PDF_BASE = "https://ecma-international.org/wp-content/uploads/"
HTML_URL = "https://262.ecma-international.org/17.0/"
SOURCES = [
    ("1st edition (1997)", "pdf", "ECMA-262_1st_edition_june_1997.pdf", "cccbe1a1f1a653ddc864ab396987a4fba288acbdd06b1a4bab49fe61ff9a73fc"),
    ("2nd edition (1998)", "pdf", "ECMA-262_2nd_edition_august_1998.pdf", "f037ad7b405d32c16e8b40bb970459d3e485419411a427f518b1732ac8a78121"),
    ("3rd edition (1999)", "pdf", "ECMA-262_3rd_edition_december_1999.pdf", "752717984fd8f6daeccc4414d39998b01aa95683bbb023c64655d52c40d2fc47"),
    ("5th edition (2009)", "pdf", "ECMA-262_5th_edition_december_2009.pdf", "d19ea217f1a70022fd5ca9bf9292f922d99558470dde6932aa4037a5df9faa7b"),
    ("5.1 edition (2011)", "pdf", "ECMA-262_5.1_edition_june_2011.pdf", "ba56aac6044735047085f9766ad757519a8605ca43e011a696c0386316f587e4"),
    ("17th edition (2026)", "html", "17.0", "5df49e088c2b5c7a3dfd4a330414b92897fb4535cb62fc5936cad101a6c2304a"),
]


def fetch(cache_dir, kind, ref, expected):
    os.makedirs(cache_dir, exist_ok=True)
    path = os.path.join(cache_dir, ref if kind == "pdf" else "ecma-262-%s.html" % ref)
    url = PDF_BASE + ref if kind == "pdf" else HTML_URL
    if not os.path.exists(path):
        req = urllib.request.Request(url, headers={"User-Agent": "whose-maths-spec/1.0"})
        with urllib.request.urlopen(req, timeout=180) as r, open(path, "wb") as f:
            f.write(r.read())
    digest = hashlib.sha256(open(path, "rb").read()).hexdigest()
    if digest != expected:
        sys.exit("sha256 mismatch for %s\n  expected %s\n  got      %s\nDelete %s and retry; if the file really changed, say so in the README before updating the hash."
                 % (url, expected, digest, path))
    return path


def join_lines(lines):
    """Join wrapped lines, re-joining words split by a hyphen at a line end."""
    out = ""
    for line in (l.strip() for l in lines):
        if not line:
            continue
        if out.endswith("-") and line[:1].islower():
            out += line
        else:
            out = (out + " " + line) if out else line
    return re.sub(r"\s+", " ", out)


def pdf_intro(path):
    txt = subprocess.run(["pdftotext", "-layout", path, "-"], capture_output=True, text=True, errors="ignore", check=True).stdout
    lines = txt.split("\n")
    toc = re.compile(r"(?:\.\s?){4,}\s*\d*\s*$")
    first = next(i for i, l in enumerate(lines) if re.match(r"^\s*15\.8\.2\.1\s+abs", l) and not toc.search(l))
    head = max(i for i in range(first) if re.match(r"^\s*15\.8\.2\s+Function Properties of the Math Object", lines[i]) and not toc.search(lines[i]))
    return join_lines(lines[head + 1: first])


def html_intro(path):
    page = open(path, encoding="utf-8").read()
    start = page.find('<emu-clause id="sec-function-properties-of-the-math-object"')
    end = page.find('<emu-clause id="sec-math.abs"', start)
    text = re.sub(r"<[^>]+>", "", page[start:end])
    text = html.unescape(text).replace(" ", " ")
    text = re.sub(r"^\s*21\.3\.2\s+Function Properties of the Math Object", "", text.strip())
    return re.sub(r"\s+", " ", text).strip()


def sentences(text):
    return re.split(r"(?<=[.])\s+(?=[A-Z])", text)


def main():
    cache_dir = os.environ.get("SPEC_CACHE_DIR") or os.path.join(tempfile.gettempdir(), "whose-maths-spec-cache")
    out_dir = os.environ.get("SPEC_OUT_DIR") or os.path.dirname(os.path.abspath(__file__))
    lines, problems = [], []
    for label, kind, ref, sha in SOURCES:
        path = fetch(cache_dir, kind, ref, sha)
        intro = pdf_intro(path) if kind == "pdf" else html_intro(path)
        sents = sentences(intro)
        named = next((s for s in sents if "not precisely specified" in s), "")
        intent = next((s for s in sents if "same mathematical library" in s), "")
        fdlibm = [s for s in sents if "fdlibm" in s]
        listed = re.sub(r"^.*?The behaviou?r of the functions\s+", "", named.split(" is not precisely specified")[0])
        names = [n for n in re.split(r",\s*(?:and\s+)?|\s+and\s+", listed) if n]
        spelling = re.search(r"\bimplement(or|er)\b", intent)
        lines.append("%s, %s" % (label, "15.8.2" if kind == "pdf" else "21.3.2"))
        in_note = bool(re.match(r"^\s*NOTE\b", named, re.I))
        lines.append("  functions named (%d): %s" % (len(names), ", ".join(names)))
        lines.append("  the passage opens with the label NOTE: %s" % ("yes" if in_note else "no"))
        lines.append("  spelling in the same-library sentence: %s" % (spelling.group(0) if spelling else "NOT FOUND"))
        lines.append("  same-library sentence: %s" % intent)
        for s in fdlibm:
            lines.append("  fdlibm: %s" % s)
        lines.append("")
        if not named or not intent or not fdlibm or not spelling:
            problems.append("%s: an expected sentence was not found" % label)
        if label.startswith("1st") and len(names) != 10:
            problems.append("1st edition names %d functions, the post says ten" % len(names))

    now = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    header = [
        "# engine:   ECMA-262 1st, 2nd, 3rd, 5th, 5.1 (PDF) and 17th (HTML) editions; sha256 in the sources lines below",
        "# platform: %s, %s, Python %s, %s" % (platform.platform(), platform.machine(), platform.python_version(),
                                              subprocess.run(["pdftotext", "-v"], capture_output=True, text=True).stderr.splitlines()[0]),
        "# obtained: downloaded from Ecma and 262.ecma-international.org with urllib, a cached download reused; sha256 checked against the table in the script",
        "# date:     %s" % now,
        "# script:   %s" % SCRIPT,
    ] + ["# source:   %s %s sha256 %s" % (label, (PDF_BASE + ref) if kind == "pdf" else HTML_URL, sha) for label, kind, ref, sha in SOURCES] + [""]
    with open(os.path.join(out_dir, "math-wording.results.txt"), "w", encoding="utf-8") as f:
        f.write("\n".join(header + lines))
    print("\n".join(lines))
    if problems:
        sys.exit("problems:\n  " + "\n  ".join(problems))


if __name__ == "__main__":
    main()
