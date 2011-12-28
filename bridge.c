#include <stdio.h>
#include <string.h>
#include <stdarg.h>

#include "bridge.h"
#include "utils.h"

int using_utf8 = 0;
int cmus_running = 1;
struct searchable *searchable;
char *lib_filename = NULL;
char *lib_ext_filename = NULL;
char *pl_filename = NULL;
char *pl_ext_filename = NULL;
char *play_queue_filename = NULL;
char *play_queue_ext_filename = NULL;
char *charset = "ISO-8859-1";
char *id3_default_charset = "ISO-8859-1";

void error_msg(const char *format, ...)
{
	va_list ap;

	va_start(ap, format);
	fprintf(stderr, format, ap);
	va_end(ap);
}

void option_add(const char *name, unsigned int id, opt_get_cb get,
		opt_set_cb set, opt_toggle_cb toggle) { }


/* destination buffer for utf8_encode and utf8_decode */
static char conv_buffer[512];

static void utf8_encode(const char *buffer)
{
	int n;
#ifdef HAVE_ICONV
	static iconv_t cd = (iconv_t)-1;
	size_t is, os;
	const char *i;
	char *o;
	int rc;

	if (cd == (iconv_t)-1) {
		d_print("iconv_open(UTF-8, %s)\n", charset);
		cd = iconv_open("UTF-8", charset);
		if (cd == (iconv_t)-1) {
			d_print("iconv_open failed: %s\n", strerror(errno));
			goto fallback;
		}
	}
	i = buffer;
	o = conv_buffer;
	is = strlen(i);
	os = sizeof(conv_buffer) - 1;
	rc = iconv(cd, (void *)&i, &is, &o, &os);
	*o = 0;
	if (rc == -1) {
		d_print("iconv failed: %s\n", strerror(errno));
		goto fallback;
	}
	return;
fallback:
#endif
	n = min(sizeof(conv_buffer) - 1, strlen(buffer));
	memmove(conv_buffer, buffer, n);
	conv_buffer[n] = '\0';
}

int cmus_playlist_for_each(const char *buf, int size, int reverse,
		int (*cb)(void *data, const char *line),
		void *data) { return 0; }
