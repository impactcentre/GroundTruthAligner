
#all-am: libgui.a

#libgui.a: AppWindow.d
#	$(DC) -lib $$(pkg-config --cflags gtkd2) -of$@ *.d

include ../d-support.mk

noinst_LIBRARIES = libgui.a
libgui_a_SOURCES = mainwindow.d

libgui_a_DFLAGS = \
	$$(pkg-config --cflags gtkd2)
libgui_a_DOC    = -D -Dd$(top_srcdir)/src/doc

AM_DFLAGS = $(libgui_a_DFLAGS)

#######
# DOC #
#######
doc:
	$(DC) -c $(AM_DFLAGS) $(DFLAGS) $(libgui_a_DOC) $(libgui_a_SOURCES)

###############
# Extra Clean #
###############
CLEANFILES = *~ $(noinst_LIBRARIES)
