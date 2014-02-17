
#all-am: libgui.a

#libgui.a: AppWindow.d
#	$(DC) -lib $$(pkg-config --cflags gtkd2) -of$@ *.d

include ../d-support.mk

noinst_LIBRARIES   = libmodel.a
libmodel_a_SOURCES = image.d xmltext.d alignmodel.d

libmodel_a_DFLAGS  = $$(pkg-config --cflags gtkd2) -I$(top_srcdir)/src
libmodel_a_DOC     = -D -Dd$(top_srcdir)/src/doc

AM_DFLAGS          = $(libmodel_a_DFLAGS)

#######
# DOC #
#######
doc:
	$(DC) -c $(AM_DFLAGS) $(DFLAGS) $(libmodel_a_DOC) $(libmodel_a_SOURCES)

###############
# Unittesting #
###############
tests:
	$(DC) -main -unittest $(AM_DFLAGS) $(DFLAGS) image.d -ofimage-test \
	    $$(pkg-config --libs gtkd2) ../mvc/modelview.o

	$(DC) -main -unittest $(AM_DFLAGS) $(DFLAGS) xmltext.d -ofxmltext-test \
            $$(pkg-config --libs gtkd2) ../mvc/modelview.o

	$(DC) -main -unittest $(AM_DFLAGS) $(DFLAGS) \
            alignmodel.d image.d xmltext.d \
            -ofalignmodel-test $$(pkg-config --libs gtkd2) ../mvc/modelview.o


pass-tests: tests
	@echo -e "\n-------[IMAGE TESTS]-----------------\n"
	./image-test
	@echo -e "\n-------------------------------------\n"
	@echo -e "\n-------[XMLTEXT TESTS]---------------\n"
	./xmltext-test
	@echo -e "\n-------------------------------------\n"
	@echo -e "\n-------[ALIGNMODEL TESTS]------------\n"
	./alignmodel-test
	@echo -e "\n-------------------------------------\n"

###############
# Extra Clean #
###############
CLEANFILES = *~ $(noinst_LIBRARIES)

.PHONY: doc tests pass-tests
