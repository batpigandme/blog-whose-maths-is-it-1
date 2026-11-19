/* sin-check.c: call the C library's sin on a double given by its bits and
 * print the result's bits.
 *
 * Usage: sin-check [INPUT_BITS_HEX]
 *   default input: 5c99c487f2337e3a, 1.1986535513718587e+138 (about 2^458)
 *
 * Build: gcc -O0 -fno-builtin -o sin-check sin-check.c -lm -ldl
 * The input goes through a volatile, and -fno-builtin stops GCC treating sin as
 * a builtin, so the call is a real call into whatever libm the loader picks.
 *
 * It also prints where the dynamic loader resolved sin, as an offset into the
 * library that holds it. glibc picks sin by an ifunc resolver on x86_64, so
 * that offset says which variant ran: match it against nm of that libm.
 */
#define _GNU_SOURCE
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>
#include <gnu/libc-version.h>

int main(int argc, char **argv) {
	volatile uint64_t in_bits = 0x5c99c487f2337e3aULL;
	volatile double x;
	volatile double y;
	uint64_t out_bits;
	double tmp;
	uint64_t b;
	void *fn;
	Dl_info info;

	if (argc > 1) {
		in_bits = strtoull(argv[1], NULL, 16);
	}
	b = in_bits;
	memcpy(&tmp, &b, sizeof tmp);
	x = tmp;
	y = sin(x);
	tmp = y;
	memcpy(&out_bits, &tmp, sizeof out_bits);
	fn = dlsym(RTLD_DEFAULT, "sin");
	if (fn != NULL && dladdr(fn, &info) != 0) {
		printf("libc=%s in=%016llx out=%016llx sin_at=%s+0x%lx\n", gnu_get_libc_version(),
			(unsigned long long)b, (unsigned long long)out_bits, info.dli_fname,
			(unsigned long)((char *)fn - (char *)info.dli_fbase));
		return 0;
	}
	printf("libc=%s in=%016llx out=%016llx sin_at=unknown\n", gnu_get_libc_version(),
		(unsigned long long)b, (unsigned long long)out_bits);
	return 0;
}
