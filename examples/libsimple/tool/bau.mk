
# This is the prolog.
O := .o
%$(O) : %.c
	$(CC) -o $@ $< $(CCFLAGS) -c
toplevel : targets
# process: ./Baufile
# outfile: tool
# sourcefiles: tool.c
./tool.o : ./tool.c
	$(CC) -o $@ $<  -I$(libsimpleINC) -c 
toolNode = ./tool.exe
./tool.exe : $(libsimpleNode)
./tool.exe : ./tool.o 
	$(CC) -o $@ $<  -L$(libsimpleLIB) -llibsimple
clean ::
	$(RM) $(RMFLAGS) ./tool.exe
	$(RM) $(RMFLAGS) ./tool.o
targets :  ./tool.exe

# This is the epilog.
