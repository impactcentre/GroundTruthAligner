
#all-am: libgui.a

#libgui.a: AppWindow.d
#	$(DC) -lib $$(pkg-config --cflags gtkd2) -of$@ *.d

include ../d-support.mk

noinst_LIBRARIES = libgui.a
libgui_a_SOURCES = AppWindow.d

libgui_a_DFLAGS = \
	$$(pkg-config --cflags gtkd2)

AM_DFLAGS = $(libgui_a_DFLAGS)
