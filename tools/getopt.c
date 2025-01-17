/*
 * Copyright © 2005-2020 Rich Felker, et al.
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

/* This implementation was taken from musl and modified for RGBDS */

#include <stddef.h>
#include <stdlib.h>
#include <limits.h>
#include <stdio.h>
#include <string.h>
#include <wchar.h>

#include "getopt.h"

char *optarg;
int optind = 1, musl_opterr = 1, musl_optopt;
int musl_optreset = 0;
static int musl_optpos;

static void musl_getopt_msg(char const *a, char const *b, char const *c, size_t l)
{
	FILE *f = stderr;

	if (fputs(a, f) >= 0 &&
	    fwrite(b, strlen(b), 1, f) &&
	    fwrite(c, 1, l, f) == l)
		putc('\n', f);
}

static int getopt(int argc, char *argv[], char const *optstring)
{
	int i;
	wchar_t c, d;
	int k, l;
	char *optchar;

	if (!optind || musl_optreset) {
		musl_optreset = 0;
		musl_optpos = 0;
		optind = 1;
	}

	if (optind >= argc || !argv[optind])
		return -1;

	if (argv[optind][0] != '-') {
		if (optstring[0] == '-') {
			optarg = argv[optind++];
			return 1;
		}
		return -1;
	}

	if (!argv[optind][1])
		return -1;

	if (argv[optind][1] == '-' && !argv[optind][2])
		return optind++, -1;

	if (!musl_optpos)
		musl_optpos++;
	k = mbtowc(&c, argv[optind] + musl_optpos, MB_LEN_MAX);
	if (k < 0) {
		k = 1;
		c = 0xfffd; /* replacement char */
	}
	optchar = argv[optind] + musl_optpos;
	musl_optpos += k;

	if (!argv[optind][musl_optpos]) {
		optind++;
		musl_optpos = 0;
	}

	if (optstring[0] == '-' || optstring[0] == '+')
		optstring++;

	i = 0;
	d = 0;
	do {
		l = mbtowc(&d, optstring+i, MB_LEN_MAX);
		if (l > 0)
			i += l;
		else
			i++;
	} while (l && d != c);

	if (d != c || c == ':') {
		musl_optopt = c;
		if (optstring[0] != ':' && musl_opterr)
			musl_getopt_msg(argv[0], ": unrecognized option: ", optchar, k);
		return '?';
	}
	if (optstring[i] == ':') {
		optarg = 0;
		if (optstring[i + 1] != ':' || musl_optpos) {
			optarg = argv[optind++] + musl_optpos;
			musl_optpos = 0;
		}
		if (optind > argc) {
			musl_optopt = c;
			if (optstring[0] == ':')
				return ':';
			if (musl_opterr)
				musl_getopt_msg(argv[0], ": option requires an argument: ",
						optchar, k);
			return '?';
		}
	}
	return c;
}

static void permute(char **argv, int dest, int src)
{
	char *tmp = argv[src];
	int i;

	for (i = src; i > dest; i--)
		argv[i] = argv[i-1];
	argv[dest] = tmp;
}

static int getopt_long_core(int argc, char **argv, char const *optstring,
				 const struct option *longopts, int *idx, int longonly);

int getopt_long(int argc, char **argv, char const *optstring,
			    const struct option *longopts, int *idx, int longonly)
{
	int ret, skipped, resumed;

	if (!optind || musl_optreset) {
		musl_optreset = 0;
		musl_optpos = 0;
		optind = 1;
	}

	if (optind >= argc || !argv[optind])
		return -1;

	skipped = optind;
	if (optstring[0] != '+' && optstring[0] != '-') {
		int i;
		for (i = optind; ; i++) {
			if (i >= argc || !argv[i])
				return -1;
			if (argv[i][0] == '-' && argv[i][1])
				break;
		}
		optind = i;
	}
	resumed = optind;
	ret = getopt_long_core(argc, argv, optstring, longopts, idx, longonly);
	if (resumed > skipped) {
		int i, cnt = optind - resumed;

		for (i = 0; i < cnt; i++)
			permute(argv, skipped, optind - 1);
		optind = skipped + cnt;
	}
	return ret;
}

static int getopt_long_core(int argc, char **argv, char const *optstring,
				 const struct option *longopts, int *idx, int longonly)
{
	optarg = 0;
	if (longopts && argv[optind][0] == '-' &&
	    ((longonly && argv[optind][1] && argv[optind][1] != '-') ||
	     (argv[optind][1] == '-' && argv[optind][2]))) {
		int colon = optstring[optstring[0] == '+' || optstring[0] == '-'] == ':';
		int i, cnt, match = 0;
		char *arg = 0, *opt, *start = argv[optind] + 1;

		for (cnt = i = 0; longopts[i].name; i++) {
			char const *name = longopts[i].name;

			opt = start;
			if (*opt == '-')
				opt++;
			while (*opt && *opt != '=' && *opt == *name) {
				name++;
				opt++;
			}
			if (*opt && *opt != '=')
				continue;
			arg = opt;
			match = i;
			if (!*name) {
				cnt = 1;
				break;
			}
			cnt++;
		}
		if (cnt == 1 && longonly && arg - start == mblen(start, MB_LEN_MAX)) {
			int l = arg - start;

			for (i = 0; optstring[i]; i++) {
				int j = 0;

				while (j < l && start[j] == optstring[i + j])
					j++;
				if (j == l) {
					cnt++;
					break;
				}
			}
		}
		if (cnt == 1) {
			i = match;
			opt = arg;
			optind++;
			if (*opt == '=') {
				if (!longopts[i].has_arg) {
					musl_optopt = longopts[i].val;
					if (colon || !musl_opterr)
						return '?';
					musl_getopt_msg(argv[0],
						": option does not take an argument: ",
						longopts[i].name,
						strlen(longopts[i].name));
					return '?';
				}
				optarg = opt + 1;
			} else if (longopts[i].has_arg == required_argument) {
				optarg = argv[optind];
				if (!optarg) {
					musl_optopt = longopts[i].val;
					if (colon)
						return ':';
					if (!musl_opterr)
						return '?';
					musl_getopt_msg(argv[0],
						": option requires an argument: ",
						longopts[i].name,
						strlen(longopts[i].name));
					return '?';
				}
				optind++;
			}
			if (idx)
				*idx = i;
			if (longopts[i].flag) {
				*longopts[i].flag = longopts[i].val;
				return 0;
			}
			return longopts[i].val;
		}
		if (argv[optind][1] == '-') {
			musl_optopt = 0;
			if (!colon && musl_opterr)
				musl_getopt_msg(argv[0], cnt ?
					": option is ambiguous: " :
					": unrecognized option: ",
					argv[optind] + 2,
					strlen(argv[optind] + 2));
			optind++;
			return '?';
		}
	}
	return getopt(argc, argv, optstring);
}

int getopt_long_only(int argc, char **argv, char const *optstring,
			  const struct option *longopts, int *idx)
{
	return getopt_long(argc, argv, optstring, longopts, idx, 1);
}
