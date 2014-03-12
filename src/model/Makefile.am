
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
MVC_LIB = ../mvc/libmvc.a
tests:
	@$(MAKE) -C ../mvc

	@$(DC) -main -unittest $(AM_DFLAGS) $(DFLAGS) image.d -ofimage-test \
	    $$(pkg-config --libs gtkd2) $(MVC_LIB)

	@$(DC) -main -unittest $(AM_DFLAGS) $(DFLAGS) xmltext.d -ofxmltext-test \
            $$(pkg-config --libs gtkd2) $(MVC_LIB)

	@$(DC) -main -unittest $(AM_DFLAGS) $(DFLAGS) \
            alignmodel.d image.d xmltext.d \
            -ofalignmodel-test $$(pkg-config --libs gtkd2) $(MVC_LIB)


pass-tests: tests
	@echo -e "\n(1)----[IMAGE TESTS BEGIN]-----------\n"
	./image-test
	@echo -e "\n-------[IMAGE TESTS END]-------------\n\n"

	@echo -e "\n(2)----[XMLTEXT TESTS BEGIN]---------\n"
	./xmltext-test
	@echo -e "\n-------[XMLTEXT TESTS END]-----------\n\n"

	@echo -e "\n(3)----[ALIGNMODEL TESTS BEGIN]------\n"
	./alignmodel-test
	@echo -e "\n-------[ALIGNMODEL TESTS END]--------\n\n"

###############
# Extra Clean #
###############
CLEANFILES = *~ $(noinst_LIBRARIES)

.PHONY: doc tests pass-tests
