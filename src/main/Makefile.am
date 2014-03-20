
include ../d-support.mk

bin_PROGRAMS      = d-images
d_images_SOURCES  = main.d $(abs_top_builddir)/src/config/constants.d

if DMD
d_images_DFLAGS             = -I$(abs_top_srcdir)/src -I$(abs_top_builddir)/src $(CORE_DEPS_CFLAGS)
d_images_LDFLAGS            = -L-L$(abs_top_builddir)/src/mvc \
                              -L-L$(abs_top_builddir)/src/view \
                              -L-L$(abs_top_builddir)/src/model
d_images_LDADD              = -L-l:libgui.a -L-l:libmvc.a \
                              -L-l:libmodel.a $(CORE_DEPS_LIBS)
EXTRA_d_images_DEPENDENCIES = $(abs_top_builddir)/src/view/libgui.a \
                              $(abs_top_builddir)/src/mvc/libmvc.a \
                              $(abs_top_builddir)/src/model/libmodel.a
d_images_DOC                = -D -Dd$(abs_top_builddir)/src/doc
else
d_images_DFLAGS   = -O2 $(CORE_DEPS_CFLAGS)
d_images_LDFLAGS  = -lsqlite3 $(CORE_DEPS_LIBS)
d_images_DOC      = -fdoc -fdoc-dir=doc
endif

AM_DFLAGS         = $(d_images_DFLAGS)

if DMD
d_images_LINK     = $(CCLD) $(AM_DFLAGS) $(DFLAGS) $(d_images_LDFLAGS) \
                    $(LDFLAGS) -of$@
else
d_images_LINK     = $(CCLD) $(AM_DFLAGS) $(DFLAGS) $(d_images_LDFLAGS) \
                    $(LDFLAGS) -o $@
endif

# qdb : main.o
# 	$(DC) $(qdb_LDFLAGS) -of$@

#######
# DOC #
#######
doc:
	for f in $(d_images_SOURCES); do \
	   $(DC) -c $(AM_DFLAGS) $(DFLAGS) $(d_images_DOC) $$f; \
	done 

###############
# Extra Clean #
###############
CLEANFILES = *~ *.o $(bin_PROGRAMS)
