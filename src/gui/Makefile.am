
all-am: libgui.a

libgui.a:
	$(DC) -lib $$(pkg-config --cflags gtkd2) -of$@ *.d
