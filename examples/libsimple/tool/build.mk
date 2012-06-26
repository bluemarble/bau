# 
# Handbuilt bau intermediate file
#

# target dependent
E := .exe
# toolchain dependent
A := .a
O := .o

CC.tool := cc
CC.defaultflags := -O2
CC.tool.incls :=

AR.tool := ar
AR.defaultflags := -rc

RM.tool := rm
RM.defaultflags := -f

#
# The standard targets...
#

.PHONY default : target
#.PHONY blat : \
#	$(NODEtool.self) \
#	$(NODElibsimple.self)


#
# preamble: Where are the nodes?
#

NODEtool.dir       := .
NODElibsimple.dir  := ../libsimple

#
# node: tool
# 

NODEtool.self := tool
NODEtool.type := executable

NODEtool.cc.flags := $(CC.defaultflags)
NODEtool.cc.incls  = -I$(NODEtool.dir) $(CC.tool.incls)
NODEtool.cc.libs   = 

# add in the external dependencies, i.e. libsimple
NODEtool.externaldeps := libsimple
NODEtool.cc.incls  += -I$(NODElibsimple.dir)
NODEtool.cc.libs   += -L$(NODElibsimple.dir) -lsimple


NODEtool.outputfile := \
	$(NODEtool.dir)/$(NODEtool.self)$(E)

NODEtool.objectfiles := \
	$(NODEtool.dir)/tool$(O)

NODEtool.sourcefiles := \
	$(NODEtool.dir)/tool.c

# tool.exe <- tool.o + external-deps
$(NODEtool.outputfile) : $(NODEtool.externaldeps) $(NODEtool.objectfiles) 
	$(CC.tool) -o $@ $(NODEtool.objectfiles) $(NODEtool.cc.libs)

# tool.o <- tool.c
NODEtool.tool.hdrs := \
	$(NODElibsimple.dir)/libsimple.h \
	$(NODEtool.dir)/tool.h \
	/usr/include/stdio.h
$(NODEtool.dir)/tool$(O) : $(NODEtool.dir)/tool.c $(NODEtool.tool.hdrs)
	$(CC.tool) $(NODEtool.cc.flags) -o $@ $(NODEtool.dir)/tool.c -c $(NODEtool.cc.incls) 

# node-specific targets

$(NODEtool.self) : $(NODEtool.outputfile)

$(NODEtool.self).clean  :
	$(RM.tool) $(RM.defaultflags) $(NODEtool.objectfiles)
	$(RM.tool) $(RM.defaultflags) $(NODEtool.outputfile)

#
# node: libsimple
#

NODElibsimple.self := libsimple
NODElibsimple.type := library-static

NODElibsimple.cc.flags := $(CC.defaultflags)
NODElibsimple.cc.incls  = -I$(NODElibsimple.dir) $(CC.tool.incls)
NODElibsimple.cc.libs   = 

NODElibsimple.outputfile := \
	$(NODElibsimple.dir)/$(NODElibsimple.self)$(A)

NODElibsimple.objectfiles := \
	$(NODElibsimple.dir)/foo$(O) \
	$(NODElibsimple.dir)/bar$(O) \
	$(NODElibsimple.dir)/faz$(O) 

NODElibsimple.sourcefiles := \
	$(NODElibsimple.dir)/foo.c \
	$(NODElibsimple.dir)/bar.c \
	$(NODElibsimple.dir)/faz.c

$(NODElibsimple.outputfile) : $(NODElibsimple.objectfiles)
	$(AR.tool) $(AR.defaultflags) $@ $(NODElibsimple.objectfiles)

$(NODElibsimple.dir)/foo$(O) : $(NODElibsimple.dir)/foo.c $(NODElibsimple.dir)/libsimple.h
	$(CC.tool) $(NODElibsimple.cc.flags) -o $@ $(NODElibsimple.dir)/foo.c -c $(NODElibsimple.cc.incls)
$(NODElibsimple.dir)/bar$(O) : $(NODElibsimple.dir)/bar.c $(NODElibsimple.dir)/libsimple.h
	$(CC.tool) $(NODElibsimple.cc.flags) -o $@ $(NODElibsimple.dir)/bar.c -c $(NODElibsimple.cc.incls)
$(NODElibsimple.dir)/faz$(O) : $(NODElibsimple.dir)/faz.c $(NODElibsimple.dir)/libsimple.h
	$(CC.tool) $(NODElibsimple.cc.flags) -o $@ $(NODElibsimple.dir)/faz.c -c $(NODElibsimple.cc.incls)

# node-specific targets

$(NODElibsimple.self) : $(NODElibsimple.outputfile)

$(NODElibsimple.self).clean  :
	$(RM.tool) $(RM.defaultflags) $(NODElibsimple.objectfiles)
	$(RM.tool) $(RM.defaultflags) $(NODElibsimple.outputfile)

# 
# postscript: after tree parse, tell us what the default target is...
# 

.PHONY target : $(NODEtool.self)
.PHONY help:
	echo "Help..."

.PHONY clean  : \
	$(NODEtool.self).clean \
	$(NODElibsimple.self).clean

#
# End of file
#
