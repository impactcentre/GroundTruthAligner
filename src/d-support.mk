######################
# D language support #
############################################################
SUFFIXES = .d .di
OBJEXT   = o
DC       = @DC@
CCLD     = $(DC)

if DMD
.d.o:
	$(DC) $(DFLAGS) $(AM_DFLAGS) -c $< -of$@
else
.d.o:
	$(DC) $(DFLAGS) $(AM_DFLAGS) -c $< -o $@
endif
############################################################

