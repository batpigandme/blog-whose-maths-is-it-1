# java-math

Backs the post's footnote `[^java-math]`: "Rhino and GraalJS build on Java's `Math`, which is 'not defined to return the bit-for-bit same results.'"

A recorded quotation from Java's documentation, not a run. Nothing here was regenerated.

## Claim

`java.lang.Math` isn't defined to return the same bits on every platform, and many of its methods call the equivalent method in `java.lang.StrictMath`, which the documentation specifies by fdlibm's algorithms.

## Tier

c: results only.

## The recorded reading

**Source:** Oracle, [`java.lang.Math`](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/lang/Math.html), Java SE 25 documentation; and [`java.lang.StrictMath`](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/lang/StrictMath.html), the same version.

**Date recorded:** 2026-11-16. The documentation pages aren't pinned to a commit, so what was read is below.

**`java.lang.Math`:**

- The class says its methods are "not defined to return the bit-for-bit same results", the wording the post quotes.
- "Many of the Math methods simply call the equivalent method in StrictMath."

**`java.lang.StrictMath`:** its algorithms are specified by fdlibm, "to help ensure portability."

**Where the engines call it, at the commits the post links:** Rhino in [`NativeMath.java` at `7386aa0`](https://github.com/mozilla/rhino/blob/7386aa037d9a8020e4e69cc0af11eb73fe59d09d/rhino/src/main/java/org/mozilla/javascript/NativeMath.java#L588), and GraalJS in [`SinNode.java` at 25.0.3](https://github.com/oracle/graaljs/blob/eba5be12437ddf85b56b6d50180ce93e6769f72b/graal-js/src/com.oracle.truffle.js/src/com/oracle/truffle/js/builtins/math/SinNode.java).

**Platform:** not applicable; this is a reading of documentation.

## Scope

- This records the Java SE 25 documentation as read on one day; Oracle's pages can change, and no copy is committed or hashed.
- The documentation says many methods call `StrictMath`; which code runs on a given Java virtual machine, an intrinsic or `StrictMath`, isn't checked here.
- The engines' call sites are links to the pinned source, not a reading recorded in this folder.
