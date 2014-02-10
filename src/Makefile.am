
SUBDIRS = gui main

doc:
	for d in $(SUBDIRS); \
	do \
	  $(MAKE) -C $$d $@ ; \
	done;

.PHONY: doc
