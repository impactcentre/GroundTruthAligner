
#all-am: libgui.a

#libgui.a: AppWindow.d
#	$(DC) -lib $$(pkg-config --cflags gtkd2) -of$@ *.d

include ../d-support.mk

noinst_LIBRARIES = libapp.a
libapp_a_SOURCES = application.d

libapp_a_DFLAGS  = $$(pkg-config --cflags gtkd2) -I$(abs_top_srcdir)/src -I$(abs_top_builddir)/src 
libapp_a_DOC     = -D -Dd$(top_srcdir)/src/doc

AM_DFLAGS = $(libapp_a_DFLAGS)

#######
# DOC #
#######
doc:
	$(DC) -c $(AM_DFLAGS) $(DFLAGS) $(libapp_a_DOC) $(libapp_a_SOURCES)

###############
# Extra Clean #
###############
CLEANFILES = *~ $(noinst_LIBRARIES)
