// llvm-atan-fma.cc -- LLVM libc's shared::atan, as V8 15.x calls it
// (src/base/ieee754.cc), on the hex inputs of a case file (lib/gen-cases.js,
// Math.atan.txt) read from standard input. Prints result bits, one per line,
// and says on standard error which multiply_add path the build took.
//
//   clang++ -std=c++20 -O2 -DLIBC_NAMESPACE=__llvm_libc_cr -I <libc checkout> llvm-atan-fma.cc
//
// Built by run-atan-mac.sh and in-container-atan.sh.
#include <cstdio>
#include <cstdint>
#include <cstring>
#include "shared/math.h"
int main() {
	char fn[64]; unsigned long long xb, fb;
	while (std::scanf("%63s %llx %llx", fn, &xb, &fb) == 3) {
		double x; std::memcpy(&x, &xb, 8);
		double y = LIBC_NAMESPACE::shared::atan(x);
		uint64_t yb; std::memcpy(&yb, &y, 8);
		std::printf("%016llx\n", (unsigned long long)yb);
	}
#if defined(__ARM_FEATURE_FMA) || (defined(__AVX2__) && defined(__FMA__))
	std::fprintf(stderr, "LIBC_TARGET_CPU_HAS_FMA path\n");
#else
	std::fprintf(stderr, "no-FMA path\n");
#endif
}
