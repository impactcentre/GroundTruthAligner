EXTRA_DIST  = ui/*.ui
SUBDIRS     = app mvc model view utils main
TESTSUBDIRS = model

doc:
	for d in $(SUBDIRS); \
	do \
	  $(MAKE) -C $$d $@ ; \
	done;

tests:
	for d in $(TESTSUBDIRS); \
	do \
	  $(MAKE) -C $$d $@ ; \
	done;

pass-tests: 
	for d in $(TESTSUBDIRS); \
	do \
	  $(MAKE) -C $$d $@ ; \
	done;

.PHONY: doc tests pass-tests
