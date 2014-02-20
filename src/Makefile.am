
SUBDIRS     = mvc model view main
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

pass-tests: tests
	for d in $(TESTSUBDIRS); \
	do \
	  $(MAKE) -C $$d $@ ; \
	done;

.PHONY: doc tests pass-tests
