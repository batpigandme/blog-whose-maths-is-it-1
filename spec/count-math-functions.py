#!/usr/bin/env python3
"""Count the function properties of `Math` in every edition of ECMA-262.

Backs the post's footnote on the count per edition (18 in the 1st to the 5.1
edition, 35 in the 6th to the 15th, 36 in the 16th, 37 in the 17th) and the
1st edition's `Math` functions by clause, 15.8.2.1 to 15.8.2.18.

Usage:
    python3 -I spec/count-math-functions.py

Environment:
    SPEC_CACHE_DIR   where the downloaded editions are kept, outside the repo.
                     Default: <system temp dir>/whose-maths-spec-cache
    SPEC_OUT_DIR     where the outputs are written.
                     Default: the directory this script is in.

Downloads the 1st, 2nd, 3rd, 5th, and 5.1 editions as PDFs from Ecma and the
6th (ES2015) to 17th (ES2026) as HTML from 262.ecma-international.org, checks
each file's sha256 against the table below (stopping with an error if one
differs), and counts from each edition's own text. The PDFs are read with
poppler's `pdftotext -layout`, which must be on PATH. Standard library
otherwise. macOS or Linux. About 90 MB of downloads, a few minutes.

The rule, the same in every edition:

    A function property of Math is a clause heading "Math.<name> ( ... )" in
    the Function Properties of the Math Object clause (20.2.2 in the 6th
    edition, 20.3.2 in the 7th to 12th, 21.3.2 from the 13th), or, in the 1st
    to 5.1 editions, a heading "<name> ( ... )" numbered 15.8.2.N.

Value properties (the constants) and Math[@@toStringTag], which the 6th
edition added, are not functions and aren't counted. Headings in the contents
pages are skipped. Each count is checked against the figure the post gives;
a difference stops the script after the outputs are written.
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

SCRIPT = "spec/count-math-functions.py"
PDF_BASE = "https://ecma-international.org/wp-content/uploads/"
HTML_BASE = "https://262.ecma-international.org/"

# (edition label, short name, year, kind, file or version, sha256)
SOURCES = [
    ("1st", "ES1", 1997, "pdf", "ECMA-262_1st_edition_june_1997.pdf", "cccbe1a1f1a653ddc864ab396987a4fba288acbdd06b1a4bab49fe61ff9a73fc"),
    ("2nd", "ES2", 1998, "pdf", "ECMA-262_2nd_edition_august_1998.pdf", "f037ad7b405d32c16e8b40bb970459d3e485419411a427f518b1732ac8a78121"),
    ("3rd", "ES3", 1999, "pdf", "ECMA-262_3rd_edition_december_1999.pdf", "752717984fd8f6daeccc4414d39998b01aa95683bbb023c64655d52c40d2fc47"),
    ("5th", "ES5", 2009, "pdf", "ECMA-262_5th_edition_december_2009.pdf", "d19ea217f1a70022fd5ca9bf9292f922d99558470dde6932aa4037a5df9faa7b"),
    ("5.1", "ES5.1", 2011, "pdf", "ECMA-262_5.1_edition_june_2011.pdf", "ba56aac6044735047085f9766ad757519a8605ca43e011a696c0386316f587e4"),
    ("6th", "ES2015", 2015, "html", "6.0", "4d4243dc2f04c9cdd09498f2cc2af6f6cdc07b0430da5578e7cf440d4f7846a0"),
    ("7th", "ES2016", 2016, "html", "7.0", "4feb2067bdc0f87c4f96c57d6f23b87aee420600ee9f8ea45da92cd2157c3740"),
    ("8th", "ES2017", 2017, "html", "8.0", "6ed5f0c60abfa25439a7dd3a1b56d64bd5a507681c98b6af00916e26b3a7e032"),
    ("9th", "ES2018", 2018, "html", "9.0", "035e809154ffcab5f0018b3692a9220f5233fd71efc734a285be62232fda52a2"),
    ("10th", "ES2019", 2019, "html", "10.0", "36906ca3fdf102aef621487c34c3f1b1f12fa11a4e58cd12c9e9c00013e298f0"),
    ("11th", "ES2020", 2020, "html", "11.0", "e9797ccca974ee27ed1d7be1bd20d02bad82b30d506c6f50fae147fe2498a99c"),
    ("12th", "ES2021", 2021, "html", "12.0", "6728f494a385e66fad94d4f44a7677c7c09439430a3c2f673e88ea5f6ec68f0a"),
    ("13th", "ES2022", 2022, "html", "13.0", "91e41a7b90db6fb3220b960a222abb108bdc17c42f5e74efe07acb0a25a49efc"),
    ("14th", "ES2023", 2023, "html", "14.0", "031ca0d5635b051a0f3192520013bb8f1b258a5d0503d0f83a257902afda50cd"),
    ("15th", "ES2024", 2024, "html", "15.0", "eabb3c1fc6c5b0610b143ef7bea8de7c0f323a777d669a453e47c39a2986c846"),
    ("16th", "ES2025", 2025, "html", "16.0", "6a28f9423133ed7b7c59a40baf620c2740f12f0bc9c251042f2a85b9cc5ed713"),
    ("17th", "ES2026", 2026, "html", "17.0", "5df49e088c2b5c7a3dfd4a330414b92897fb4535cb62fc5936cad101a6c2304a"),
]

# What the post states for each edition's count.
EXPECTED = {"1st": 18, "2nd": 18, "3rd": 18, "5th": 18, "5.1": 18}
EXPECTED.update({e: 35 for e in ("6th", "7th", "8th", "9th", "10th", "11th", "12th", "13th", "14th", "15th")})
EXPECTED.update({"16th": 36, "17th": 37})


def url_for(kind, ref):
    return PDF_BASE + ref if kind == "pdf" else "%s%s/" % (HTML_BASE, ref)


def fetch(cache_dir, kind, ref, expected):
    os.makedirs(cache_dir, exist_ok=True)
    path = os.path.join(cache_dir, ref if kind == "pdf" else "ecma-262-%s.html" % ref)
    if not os.path.exists(path):
        req = urllib.request.Request(url_for(kind, ref), headers={"User-Agent": "whose-maths-spec/1.0"})
        with urllib.request.urlopen(req, timeout=180) as r, open(path, "wb") as f:
            f.write(r.read())
    digest = hashlib.sha256(open(path, "rb").read()).hexdigest()
    if digest != expected:
        sys.exit(
            "sha256 mismatch for %s\n  expected %s\n  got      %s\n"
            "Delete %s and retry; if the file really changed, say so in the README before updating the hash."
            % (url_for(kind, ref), expected, digest, path)
        )
    return path


def from_pdf(path):
    """[(clause, name)] for headings 15.8.2.N in an ES1 to ES5.1 PDF."""
    txt = subprocess.run(["pdftotext", "-layout", path, "-"], capture_output=True, text=True, errors="ignore", check=True).stdout
    out, seen = [], set()
    for line in txt.split("\n"):
        if re.search(r"(?:\.\s?){4,}\s*\d*\s*$", line):  # a contents line with dot leaders
            continue
        m = re.match(r"^\s*(15\.8\.2\.\d+)\s+(\w+)\s*\(", line)
        if m and m.groups() not in seen:
            seen.add(m.groups())
            out.append(m.groups())
    return sorted(out, key=lambda kv: int(kv[0].rsplit(".", 1)[1]))


def from_html(path):
    """[(clause, name)] for the Math.<name> headings in the function-properties clause."""
    page = open(path, encoding="utf-8", errors="ignore").read()
    heads = []
    for m in re.finditer(r'<h1[^>]*>\s*<span class="secnum"[^>]*>(.*?)</span>(.*?)</h1>', page, re.S):
        num = re.sub(r"<[^>]+>", "", m.group(1)).strip()
        text = re.sub(r"<span class=\"utils\">.*", "", m.group(2), flags=re.S)
        text = re.sub(r"\s+", " ", html.unescape(re.sub(r"<[^>]+>", "", text))).replace(" ", " ").strip()
        heads.append((num, text))
    prefix = None
    out = []
    for num, text in heads:
        if prefix is None:
            if text == "Function Properties of the Math Object":
                prefix = num + "."
            continue
        if not num.startswith(prefix):
            break
        m = re.match(r"^Math\.(\w+)\s*\(", text)
        if m:
            out.append((num, m.group(1)))
    return out


def main():
    cache_dir = os.environ.get("SPEC_CACHE_DIR") or os.path.join(tempfile.gettempdir(), "whose-maths-spec-cache")
    out_dir = os.environ.get("SPEC_OUT_DIR") or os.path.dirname(os.path.abspath(__file__))

    rows, clauses, prev, bad = [], [], None, []
    for label, short, year, kind, ref, sha in SOURCES:
        path = fetch(cache_dir, kind, ref, sha)
        found = from_pdf(path) if kind == "pdf" else from_html(path)
        names = [n for _, n in found]
        if len(set(names)) != len(names):
            bad.append("%s has a repeated name" % label)
        added = [n for n in names if prev is not None and n not in prev]
        removed = [n for n in (prev or []) if n not in names]
        rows.append((label, short, year, len(names), added, removed, sha, kind, ref))
        for num, n in found:
            clauses.append((label, short, num, n))
        if len(names) != EXPECTED[label]:
            bad.append("%s: counted %d, the post says %d" % (label, len(names), EXPECTED[label]))
        prev = names

    now = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    header = [
        "# engine:   ECMA-262, 17 editions (1st to 17th), each from its own text; sources and sha256 in the sources lines below",
        "# platform: %s, %s, Python %s, %s" % (platform.platform(), platform.machine(), platform.python_version(),
                                              subprocess.run(["pdftotext", "-v"], capture_output=True, text=True).stderr.splitlines()[0]),
        "# obtained: downloaded from Ecma (PDFs, 1st to 5.1) and 262.ecma-international.org (HTML, 6th to 17th) with urllib, a cached download reused; sha256 checked against the table in the script",
        "# date:     %s" % now,
        "# script:   %s" % SCRIPT,
    ]
    sources = ["# source:   %s (%s) %s sha256 %s" % (label, short, url_for(kind, ref), sha)
               for label, short, year, kind, ref, sha in SOURCES]

    with open(os.path.join(out_dir, "math-function-counts.tsv"), "w", encoding="utf-8") as f:
        f.write("\n".join(header + sources) + "\n")
        f.write("edition\tname\tyear\tmath_functions\tadded\tremoved\n")
        for label, short, year, n, added, removed, *_ in rows:
            f.write("%s\t%s\t%d\t%d\t%s\t%s\n" % (label, short, year, n, ",".join(added), ",".join(removed)))

    with open(os.path.join(out_dir, "math-functions.tsv"), "w", encoding="utf-8") as f:
        f.write("\n".join(header + sources) + "\n")
        f.write("edition\tname\tclause\tfunction\n")
        for label, short, num, n in clauses:
            f.write("%s\t%s\t%s\t%s\n" % (label, short, num, n))

    print("\n".join("%-5s %-7s %d  added: %s" % (r[0], r[1], r[3], ",".join(r[4])) for r in rows))
    if bad:
        sys.exit("counts differ from the post:\n  " + "\n  ".join(bad))


if __name__ == "__main__":
    main()
