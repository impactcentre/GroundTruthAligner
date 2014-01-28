
all-am: libgui.a

libgui.a: AppWindow.d
	$(DC) -lib $$(pkg-config --cflags gtkd2) -of$@ *.d
