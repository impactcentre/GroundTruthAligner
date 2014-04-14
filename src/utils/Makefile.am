
#all-am: libgui.a

#libgui.a: AppWindow.d
#	$(DC) -lib $$(pkg-config --cflags gtkd2) -of$@ *.d

include ../d-support.mk

noinst_LIBRARIES = libutils.a
libutils_a_SOURCES = statistic.d

libutils_a_DFLAGS  = -I$(top_srcdir)/src $$(pkg-config --cflags gtkd2)
libutils_a_DOC     = -D -Dd$(top_srcdir)/src/doc

AM_DFLAGS = $(libutils_a_DFLAGS)

#######
# DOC #
#######
doc:
	$(DC) -c $(AM_DFLAGS) $(DFLAGS) $(libutils_a_DOC) $(libutils_a_SOURCES)

###############
# Extra Clean #
###############
CLEANFILES = *~ $(noinst_LIBRARIES)
