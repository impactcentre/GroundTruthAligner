
#all-am: libgui.a

#libgui.a: AppWindow.d
#	$(DC) -lib $$(pkg-config --cflags gtkd2) -of$@ *.d

include ../d-support.mk

noinst_LIBRARIES = libmvc.a
libmvc_a_SOURCES = modelview.d set.d

libmvc_a_DFLAGS  = $$(pkg-config --cflags gtkd2) -I..
libmvc_a_DOC     = -D -Dd$(top_srcdir)/src/doc

AM_DFLAGS = $(libmvc_a_DFLAGS)

#######
# DOC #
#######
doc:
	$(DC) -c $(AM_DFLAGS) $(DFLAGS) $(libmvc_a_DOC) $(libmvc_a_SOURCES)

###############
# Extra Clean #
###############
CLEANFILES = *~ $(noinst_LIBRARIES)
