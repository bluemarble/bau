#!/bin/bash

isFunction()
{
   local funcName="$1"
   if [ "$(type -t "$funcName")" == "function" ] ; then
      return 0
   fi
   return 1
}


NODElibsimple.

###
srcdir : where we find the source files
objdir : defaults to the srcdir... should be computed

NODEtool.emit()
{
   # deps for the tools source
   # tool$E <- object-files
   # tool$O <- tool.c
   # tool$O <- {NODEtool.srcdir}/tool.h  # inferred

   # external deps
   # depends on a library : 'simple'
   # mapping : libsimple.a <- simple
}
