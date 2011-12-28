#ifndef _BRIDGE_H
#define _BRIDGE_H

typedef void (*opt_get_cb)(unsigned int id, char *buf);
typedef void (*opt_set_cb)(unsigned int id, const char *buf);
typedef void (*opt_toggle_cb)(unsigned int id);

extern int using_utf8;
extern int cmus_running;
extern struct searchable *searchable;
extern char *lib_filename;
extern char *lib_ext_filename;
extern char *pl_filename;
extern char *pl_ext_filename;
extern char *play_queue_filename;
extern char *play_queue_ext_filename;
extern char *charset;
extern char *id3_default_charset;

extern void error_msg(const char *format, ...);
extern void option_add(const char *name, unsigned int id, opt_get_cb get,
		opt_set_cb set, opt_toggle_cb toggle);

#endif
