
include ../d-support.mk

bin_PROGRAMS = d-images
d_images_SOURCES  = main.d $(top_srcdir)/src/config/constants.d

if DMD
d_images_DFLAGS   = -I$(top_srcdir)/src -gc -gs -unittest $(CORE_DEPS_CFLAGS)
d_images_LDFLAGS  = -gc -L-L$(top_srcdir)/src/gui
d_images_LDADD    = -L-l:libgui.a $(CORE_DEPS_LIBS)
d_images_DOC      = -D -Ddoc
else
d_images_DFLAGS   = -O2 $(CORE_DEPS_CFLAGS)
d_images_LDFLAGS  = -lsqlite3 $(CORE_DEPS_LIBS)
d_images_DOC      = -fdoc -fdoc-dir=doc
endif

DFLAGS       = $(d_images_DFLAGS)

if DMD
d_images_LINK     = $(CCLD) $(AM_DFLAGS) $(DFLAGS) $(d_images_LDFLAGS) $(LDFLAGS) -of$@
else
d_images_LINK     = $(CCLD) $(AM_DFLAGS) $(DFLAGS) $(d_images_LDFLAGS) $(LDFLAGS) -o $@
endif

# qdb : main.o
# 	$(DC) $(qdb_LDFLAGS) -of$@

doc:
	$(DC) -c $(d_images_DOC) *.d
