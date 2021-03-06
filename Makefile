REV	= HEAD

# version from an annotated tag
_ver0	= $(shell git describe $(REV) 2>/dev/null)
# version from a plain tag
_ver1	= $(shell git describe --tags $(REV) 2>/dev/null)
# SHA1
_ver2	= $(shell git rev-parse --verify --short $(REV) 2>/dev/null)
# hand-made
_ver3	= v2.4.3

VERSION	= $(or $(_ver0),$(_ver1),$(_ver2),$(_ver3))

all: main plugins #man #disabled for now

include config.mk
include scripts/lib.mk

CFLAGS += -D_FILE_OFFSET_BITS=64
CFLAGS += -I.

CMUS_LIBS = $(PTHREAD_LIBS) $(ICONV_LIBS) $(DL_LIBS) -lm $(COMPAT_LIBS)

input.o main.o pulse.lo: .version
input.o main.o pulse.lo: CFLAGS += -DVERSION=\"$(VERSION)\"
main.o server.o: CFLAGS += -DDEFAULT_PORT=3000

.version: Makefile
	@test "`cat $@ 2> /dev/null`" = "$(VERSION)" && exit 0; \
	echo "   GEN    $@"; echo $(VERSION) > $@

# programs {{{
cmus-y := \
	player.o debug.o locking.o buffer.o track_info.o \
	input.o output.o xmalloc.o keyval.o comment.o http.o \
	u_collate.o misc.o uchar.o mergesort.o pcm.o \
	gbuf.o file.o prog.o convert.o xstrjoin.o id3.o \
	read_wrapper.o ape.o bridge.o

$(cmus-y): CFLAGS += $(PTHREAD_CFLAGS) $(ICONV_CFLAGS) $(DL_CFLAGS) $(SOFLAGS)

ifeq (y,$(STANDALONE_PLUGINS))
	PLUGIN_LIBS = -lcmus -L.
endif

libcmus$(LIB_EXT): $(cmus-y)
	$(call cmd,ld_dl,$(CMUS_LIBS))

# }}}

# input plugins {{{
flac-objs		:= ip/flac.lo
mad-objs		:= ip/mad.lo ip/nomad.lo
mikmod-objs		:= ip/mikmod.lo
modplug-objs	:= ip/modplug.lo
mpc-objs		:= ip/mpc.lo
vorbis-objs		:= ip/vorbis.lo
wavpack-objs	:= ip/wavpack.lo
wav-objs		:= ip/wav.lo
mp4-objs		:= ip/mp4.lo
aac-objs		:= ip/aac.lo
ffmpeg-objs		:= ip/ffmpeg.lo

ip-$(CONFIG_FLAC)		+= ip/flac$(LIB_EXT)
ip-$(CONFIG_MAD)		+= ip/mad$(LIB_EXT)
ip-$(CONFIG_MIKMOD)		+= ip/mikmod$(LIB_EXT)
ip-$(CONFIG_MODPLUG)	+= ip/modplug$(LIB_EXT)
ip-$(CONFIG_MPC)		+= ip/mpc$(LIB_EXT)
ip-$(CONFIG_VORBIS)		+= ip/vorbis$(LIB_EXT)
ip-$(CONFIG_WAVPACK)	+= ip/wavpack$(LIB_EXT)
ip-$(CONFIG_WAV)		+= ip/wav$(LIB_EXT)
ip-$(CONFIG_MP4)		+= ip/mp4$(LIB_EXT)
ip-$(CONFIG_AAC)		+= ip/aac$(LIB_EXT)
ip-$(CONFIG_FFMPEG)		+= ip/ffmpeg$(LIB_EXT)

$(flac-objs):		CFLAGS += $(FLAC_CFLAGS)
$(mad-objs):		CFLAGS += $(MAD_CFLAGS)
$(mikmod-objs):		CFLAGS += $(MIKMOD_CFLAGS)
$(modplug-objs):	CFLAGS += $(MODPLUG_CFLAGS)
$(mpc-objs):		CFLAGS += $(MPC_CFLAGS)
$(vorbis-objs):		CFLAGS += $(VORBIS_CFLAGS)
$(wavpack-objs):	CFLAGS += $(WAVPACK_CFLAGS)
$(mp4-objs):		CFLAGS += $(MP4_CFLAGS)
$(aac-objs):		CFLAGS += $(AAC_CFLAGS)
$(ffmpeg-objs):		CFLAGS += $(FFMPEG_CFLAGS)

ip/flac$(LIB_EXT): $(flac-objs)
	$(call cmd,ld_dl,$(FLAC_LIBS) $(PLUGIN_LIBS))

ip/mad$(LIB_EXT): $(mad-objs)
	$(call cmd,ld_dl,$(MAD_LIBS) $(PLUGIN_LIBS))

ip/mikmod$(LIB_EXT): $(mikmod-objs)
	$(call cmd,ld_dl,$(MIKMOD_LIBS) $(PLUGIN_LIBS))

ip/modplug$(LIB_EXT): $(modplug-objs)
	$(call cmd,ld_dl,$(MODPLUG_LIBS) $(PLUGIN_LIBS))

ip/mpc$(LIB_EXT): $(mpc-objs)
	$(call cmd,ld_dl,$(MPC_LIBS) $(PLUGIN_LIBS))

ip/vorbis$(LIB_EXT): $(vorbis-objs)
	$(call cmd,ld_dl,$(VORBIS_LIBS) $(PLUGIN_LIBS))

ip/wavpack$(LIB_EXT): $(wavpack-objs)
	$(call cmd,ld_dl,$(WAVPACK_LIBS) $(PLUGIN_LIBS))

ip/wav$(LIB_EXT): $(wav-objs)
	$(call cmd,ld_dl,$(PLUGIN_LIBS))

ip/mp4$(LIB_EXT): $(mp4-objs)
	$(call cmd,ld_dl,$(MP4_LIBS) $(PLUGIN_LIBS))

ip/aac$(LIB_EXT): $(aac-objs)
	$(call cmd,ld_dl,$(AAC_LIBS) $(PLUGIN_LIBS))

ip/ffmpeg$(LIB_EXT): $(ffmpeg-objs)
	$(call cmd,ld_dl,$(FFMPEG_LIBS) $(PLUGIN_LIBS))

# }}}

# output plugins {{{
pulse-objs		:= op/pulse.lo
alsa-objs		:= op/alsa.lo op/mixer_alsa.lo
arts-objs		:= op/arts.lo
oss-objs		:= op/oss.lo op/mixer_oss.lo
sun-objs		:= op/sun.lo op/mixer_sun.lo
ao-objs			:= op/ao.lo
waveout-objs	:= op/waveout.lo
roar-objs		:= op/roar.lo

op-$(CONFIG_PULSE)		+= op/pulse$(LIB_EXT)
op-$(CONFIG_ALSA)		+= op/alsa$(LIB_EXT)
op-$(CONFIG_ARTS)		+= op/arts$(LIB_EXT)
op-$(CONFIG_OSS)		+= op/oss$(LIB_EXT)
op-$(CONFIG_SUN)		+= op/sun$(LIB_EXT)
op-$(CONFIG_AO)			+= op/ao$(LIB_EXT)
op-$(CONFIG_WAVEOUT)	+= op/waveout$(LIB_EXT)
op-$(CONFIG_ROAR)		+= op/roar$(LIB_EXT)

$(pulse-objs): CFLAGS	+= $(PULSE_CFLAGS)
$(alsa-objs): CFLAGS	+= $(ALSA_CFLAGS)
$(arts-objs): CFLAGS	+= $(ARTS_CFLAGS)
$(oss-objs):  CFLAGS	+= $(OSS_CFLAGS)
$(sun-objs):  CFLAGS	+= $(SUN_CFLAGS)
$(ao-objs):   CFLAGS	+= $(AO_CFLAGS)
$(waveout-objs): CFLAGS += $(WAVEOUT_CFLAGS)
$(roar-objs): CFLAGS	+= $(ROAR_CFLAGS)

op/pulse$(LIB_EXT): $(pulse-objs)
	$(call cmd,ld_dl,$(PULSE_LIBS) $(PLUGIN_LIBS))

op/alsa$(LIB_EXT): $(alsa-objs)
	$(call cmd,ld_dl,$(ALSA_LIBS) $(PLUGIN_LIBS))

op/arts$(LIB_EXT): $(arts-objs)
	$(call cmd,ld_dl,$(ARTS_LIBS) $(PLUGIN_LIBS))

op/oss$(LIB_EXT): $(oss-objs)
	$(call cmd,ld_dl,$(OSS_LIBS) $(PLUGIN_LIBS))

op/sun$(LIB_EXT): $(sun-objs)
	$(call cmd,ld_dl,$(SUN_LIBS) $(PLUGIN_LIBS))

op/ao$(LIB_EXT): $(ao-objs)
	$(call cmd,ld_dl,$(AO_LIBS) $(PLUGIN_LIBS))

op/waveout$(LIB_EXT): $(waveout-objs)
	$(call cmd,ld_dl,$(WAVEOUT_LIBS) $(PLUGIN_LIBS))

op/roar$(LIB_EXT): $(roar-objs)
	$(call cmd,ld_dl,$(ROAR_LIBS) $(PLUGIN_LIBS))
# }}}

# man {{{
man1	:= Doc/cmus.1 Doc/cmus-remote.1
man7	:= Doc/cmus-tutorial.7

$(man1): Doc/ttman
$(man7): Doc/ttman

%.1: %.txt
	$(call cmd,ttman)

%.7: %.txt
	$(call cmd,ttman)

Doc/ttman.o: Doc/ttman.c
	$(call cmd,hostcc,)

Doc/ttman: Doc/ttman.o
	$(call cmd,hostld,)

quiet_cmd_ttman = MAN    $@
      cmd_ttman = Doc/ttman $< $@
# }}}

data		= $(wildcard data/*)

clean		+= *.o *.lo *$(LIB_EXT) ip/*.o ip/*.lo ip/*$(LIB_EXT) op/*.o op/*.lo op/*$(LIB_EXT) cmus.def cmus.base cmus.exp cmus-remote Doc/*.o Doc/ttman Doc/*.1 Doc/*.7
distclean	+= .version config.mk config/*.h tags

$(ip-y) $(op-y) : libcmus$(LIB_EXT)

main: libcmus$(LIB_EXT)
plugins: $(ip-y) $(op-y)
man: $(man1) $(man7)

install-main: main
	$(INSTALL) -m755 $(libdir) libcmus$(LIB_EXT)

install-plugins: plugins
	$(INSTALL) -m755 $(libdir)/cmus/ip $(ip-y)
	$(INSTALL) -m755 $(libdir)/cmus/op $(op-y)

install-data: man
	$(INSTALL) -m644 $(datadir)/cmus $(data)
	$(INSTALL) -m644 $(mandir)/man1 $(man1)
	$(INSTALL) -m644 $(mandir)/man7 $(man7)
	$(INSTALL) -m755 $(exampledir) cmus-status-display

install: all install-main install-plugins #install-data #disabled for now

tags:
	exuberant-ctags *.[ch]

# generating tarball using GIT {{{
TARNAME	= libcmus-$(VERSION)

dist:
	@tarname=$(TARNAME);						\
	test "$(_ver2)" || { echo "No such revision $(REV)"; exit 1; };	\
	echo "   DIST   $$tarname.tar.bz2";				\
	git archive --format=tar --prefix=$$tarname/ $(REV)^{tree} | bzip2 -c -9 > $$tarname.tar.bz2

# }}}

# generate Python bindings {{{
python:
	ctypesgen.py -l libcmus track_info.h player.h input.h output.h debug.h buffer.h -o cmus.py
	sed -i -e 's/player_info = struct_player_info/#player_info = struct_player_info/' cmus.py
# }}}

.PHONY: all main plugins man dist tags
.PHONY: install install-main install-plugins install-man
