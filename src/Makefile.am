
SUBDIRS = mvc model gui main

doc:
	for d in $(SUBDIRS); \
	do \
	  $(MAKE) -C $$d $@ ; \
	done;

tests:
	for d in model; \
	do \
	  $(MAKE) -C $$d $@ ; \
	done;

.PHONY: doc tests
