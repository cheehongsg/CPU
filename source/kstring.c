#include <stdarg.h>
#include <stdio.h>
#include "kstring.h"
/* taken from samtools' kstring.c */
#include <ctype.h>
/* END - taken from samtools' kstring.c */

#ifdef USE_MALLOC_WRAPPERS
#  include "malloc_wrap.h"
#endif

int ksprintf(kstring_t *s, const char *fmt, ...)
{
	va_list ap;
	int l;
	va_start(ap, fmt);
	l = vsnprintf(s->s + s->l, s->m - s->l, fmt, ap);
	va_end(ap);
	if (l + 1 > s->m - s->l) {
		s->m = s->l + l + 2;
		kroundup32(s->m);
		s->s = (char*)realloc(s->s, s->m);
		va_start(ap, fmt);
		l = vsnprintf(s->s + s->l, s->m - s->l, fmt, ap);
	}
	va_end(ap);
	s->l += l;
	return l;
}

/* taken from samtools' kstring.c */
// s MUST BE a null terminated string; l = strlen(s)
int ksplit_core(char *s, int delimiter, int *_max, int **_offsets)
{
	int i, n, max, last_char, last_start, *offsets, l;
	n = 0; max = *_max; offsets = *_offsets;
	l = strlen(s);
	
#define __ksplit_aux do {												\
		if (_offsets) {													\
			s[i] = 0;													\
			if (n == max) {												\
				max = max? max<<1 : 2;									\
				offsets = (int*)realloc(offsets, sizeof(int) * max);	\
			}															\
			offsets[n++] = last_start;									\
		} else ++n;														\
	} while (0)
	
	for (i = 0, last_char = last_start = 0; i <= l; ++i) {
		if (delimiter == 0) {
			if (isspace(s[i]) || s[i] == 0) {
				if (isgraph(last_char)) __ksplit_aux; // the end of a field
			} else {
				if (isspace(last_char) || last_char == 0) last_start = i;
			}
		} else {
			if (s[i] == delimiter || s[i] == 0) {
				if (last_char != 0 && last_char != delimiter) __ksplit_aux; // the end of a field
			} else {
				if (last_char == delimiter || last_char == 0) last_start = i;
			}
		}
		last_char = s[i];
	}
	*_max = max; *_offsets = offsets;
	return n;
}
/* END - taken from samtools' kstring.c */


#ifdef KSTRING_MAIN
#include <stdio.h>
int main()
{
	kstring_t *s;
	s = (kstring_t*)calloc(1, sizeof(kstring_t));
	ksprintf(s, "abcdefg: %d", 100);
	printf("%s\n", s->s);
	free(s);
	return 0;
}
#endif
