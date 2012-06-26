
# This is the prolog.
O := .o
%$(O) : %.c
	$(CC) -o $@ $< $(CCFLAGS) -c
toplevel : targets
# process: ./Baufile

# This is the epilog.
