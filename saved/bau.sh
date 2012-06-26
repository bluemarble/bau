#!/bin/bash

# set up restricted environment
export LC_ALL=C
export PATH=/bin:/usr/bin:/usr/local/bluemarble/bin:/usr/local/bin

# standard external tools
export Find=/bin/find
export Make=/usr/local/bin/make
export Rm=/usr/bin/rm

# information about this tool
_cmdname="$(basename $0)"
_cmdversion="0.1a"

# global bau vars
Debug_p=f
Keep_p=f

# start hack -- include external bt functions
_spinner_nextChar='|'
_spinner()
{
   while [ $# -gt 0 ] ; do
      case "$1" in
      --start)
	 printf "$2  "
         _spinner_nextChar='|'
	 shift
         ;;
      --end)
	 printf '\b'"$2\n"
         _spinner_nextChar='|'
	 shift
         ;;
      --next)
         printf '\b'"${_spinner_nextChar}"
         case "$_spinner_nextChar" in
	    '|') _spinner_nextChar='/' ;;
	    '/') _spinner_nextChar='-' ;;
	    '-') _spinner_nextChar='\' ;;
	    '\') _spinner_nextChar='|' ;;
	 esac
         ;;
      --chars)
         # silently ignore -- this option not currently implemented
         ;;
      --)
	 shift
	 break
         ;;
      *)
         break
	 ;;
      esac
      shift
   done

   return 0
}
# end hack

# sysconf definitions
E=.exe
O=.o
# treeconf definitions
bauTreeconf="Tree.vrs"

# internal tools and utils

_bt_FindTreeVrs()
{
   local treevrs="${bauTreeconf}"
   local numTries=8
   local callback=""

   while [ $# -gt 0 ] ; do
      case "$1" in
         --callback)
	    callback="$2"
	    shift
	    ;;
	 *)
	    break
	    ;;
      esac
      shift
   done

   while [ "${numTries}" -gt 0 ] ; do
      test -n "${callback}" && eval ${callback} "${treevrs}"
      if [ -f "${treevrs}" ] ; then
	 printf "${treevrs}\n"
	 return 0
      fi
      treevrs="../${treevrs}"
      let numTries=numTries-1
   done

   _bt_Error "no treevrs found"
   return 1
}

_bt_ProcessTreeVrs()
{
   # todo: read the contents of the file, configure the source tree
   return 0
}

bauMkfile="/tmp/bau$$.mk"
bauEmit()
{
   printf "$*" >> "${bauMkfile}"
}

# errno-like record keeping
let __bt_lastError=0
_bt_LastError_get()
{
   return __bt_lastError
}
_bt_LastError_set()
{
   if [ "$1" -ne 0 ] ; then
      let __bt_lastError="$1"
   fi
}
#

let _bauLastError=0
bauGetLastError()
{
   return $_bauLastError
}
bauSetLastError()
{
   if [ "$1" -ne 0 ] ; then
      let "_bauLastError=$1"
   fi
}

_bt_Error()
{
   _spinner --end
   echo >&2 "${_cmdname}: error: $*"
   bauSetLastError 1
}
#bauError()
#{
#   _spinner --end
#   echo >&2 "${_cmdname}: error: $*"
#   bauSetLastError 1
#}
bauDebug()
{
   echo >&2 "${_cmdname}: debug: $*"
}

bauProlog()
{
   bauEmit "\n# This is the prolog.\n"
   bauEmit "O := .o\n"
   bauEmit "%%\$(O) : %%.c\n"
   bauEmit '\t$(CC) -o $@ $< $(CCFLAGS) -c\n'
   return 0
}
bauEpilog()
{
   bauEmit "\n# This is the epiolog.\n"
   return 0
}

bauTarget=""

# build tools

# int
MakeLibrary()
{
   return 0
}

# int
IncludeDirs()
{
   # command option parsing
   while [ $# -gt 0 ] ; do
      case "$1" in 
      --add|-a)
	 #bauDebug "--> CCFLAGS += -I${2}"
	 bauEmit "CCFLAGS += -I${2}\n"
         shift
	 ;;
      --del|-d)
         _bt_Error "IncludeDirs: option $1 not implemented yet."
	 return 1
	 ;;
      --) # end of options option
         shift
         break
	 ;;
      *)  # unknown option
	 break 
	 ;;
      esac
      shift
   done

   #if [ "${bauIncludeDirs}" != "" ] ; then
   #   for dir in $bauIncludeDirs ; do
   #      bauEmit 'CCFLAGS += -I '"${dir}"
   #   done
   #fi

   return 0
}

# int
MakeProgram()
{
   local input=""
   local output=""
   local derivedFileList

   local relativeDir="$bauRelDir"

   # command option parsing
   while [ $# -gt 0 ] ; do
      case "$1" in 
      --out|-o)
         bauEmit "# outfile: $2\n"
	 output="$2"
         shift
	 ;;
      --source) 
         shift 
	 bauEmit "# sourcefiles: $*\n"
	 input="$*"
	 ;;
      --include) # TODO
         shift
	 ;;
      --library) # TODO
         shift
	 ;;
      --) # end of options option
         shift
         break
	 ;;
      *)  # unknown option; perhaps a list of source files?
	 break 
	 ;;
      esac
      shift
   done

   if [ $# -gt 0 -a "$input" = "" ] ; then
      #bauDebug "remaining unparsed options: $*"
      input="$*"
   fi

   if [ "$input" = "" ] ; then
      _bt_Error "no input files specified"
      return 1
   fi

   derivedFileList=""
   for file in $input ; do
      case "$file" in
      *.c)
         derivedFile="${file%.c}${O}"
	 bauEmit "${relativeDir}/${derivedFile} : ${relativeDir}/${file}\n"
	 derivedFileList="$derivedFileList $derivedFile"
	 if [ "$output" = "" ] ; then
	    output="${file%.c}${E}"
	 fi
	 ;;
      *.cpp)
         derivedFile="${file%.cpp}${O}"
	 bauEmit "${relativeDir}/${derivedFile} : ${relativeDir}/${file}\n"
	 derivedFileList="$derivedFileList $derivedFile"
	 if [ "$output" = "" ] ; then
	    output="${file%.c}${E}"
	 fi
	 ;;
      *)
         _bt_Error "unknown file type: $file"
         return 1
	 ;;
      esac
   done

   if [ "$derivedFileList" = "" ] ; then
      _bt_Error "no intermediates derived"
      return 1
   fi
   if [ "$output" = "" ] ; then
      _bt_Error "no output specified"
      return 1
   fi

   bauEmit "${relativeDir}/${output} : "
   for derivedFile in $derivedFileList ; do
      bauEmit "${relativeDir}/${derivedFile} "
   done
   bauEmit "\n"
   bauEmit '\t$(CC) -o $@ $<\n'

   bauEmit 'clean ::\n'
   bauEmit '\t$(RM) $(RMFLAGS) '"${relativeDir}/${output}"'\n'
   for derivedFile in $derivedFileList ; do
      bauEmit '\t$(RM) $(RMFLAGS) '"${relativeDir}/${derivedFile}"'\n'
   done

   targets="$targets ${relativeDir}/${output}"

   return 0
}


#
# bau itself -- bau-engine, mainline, command-line parsing, etc.
#

_bt_bauEngine()
{
   local bauTarget="$1"
   local treevrsDir

   _spinner --start "Processing ..."

   Treevrs="$( _bt_FindTreeVrs --callback "_spinner --next" )"
   if [ $? -ne 0 ] ; then
      _bt_Error "unable to continue, will exit."
      return 1
   fi
   _spinner --next

   _bt_ProcessTreeVrs "${Treevrs}" && _spinner --next

   treevrsDir="$(dirname "${Treevrs}")" && _spinner --next

   bauCurrDir="$PWD"
   bauProlog
   bauEmit "toplevel : targets\n"
   _spinner --next

   #xyz="$( ${Find} "${treevrsDir}" -type f -name '[Bb]aufile' )"
   bauFiles="$( ${Find} . -type f -name '[Bb]aufile' )"
   _spinner --next
   for baufile in $bauFiles ; do
      bauEmit "# process: $baufile\n"

      bauRelDir="$(dirname "${baufile}")"
      bauIncludeDirs=""
      targets=""

      _spinner --next
      source "${baufile}"

      if [ "$targets" != "" ] ; then
         bauEmit "targets : ${targets}\n"
      fi
   done
   _spinner --next

   bauEpilog
   _spinner --end "done."

   "${Make}" -f "${bauMkfile}" "${bauTarget}"
   bauSetLastError $?

   if [ "${Keep_p}" != y ] ; then
      rm -f "${bauMkfile}"
   fi

   return $(bauGetLastError)
}

version()
{
   printf 'Bluemarble %s %s\n' "${_cmdname}" "${_cmdversion}"
   printf 'Copyright (C) 2005  Blue Marble.\n'
   return 0
}

usage() 
{
   echo "
Usage: ${_cmdname} [options] [target]

Options:
   --keep     leave intermediate files behind
   --debug    print debug trace
   --version  show version of ${_cmdname} tool
   --help     display this help text, then exit
   --         end of options, next arg will be target
   "
   return 0
}

main()
{
   while [ $# -gt 0 ] ; do
      case "$1" in
	 --keep)
	    Keep_p=t
	    ;;
         --debug)
            Debug_p=t
	    ;;
         --version)
            version
	    return $?
	    ;;
         --help)
            usage
	    return $?
	    ;;
         --)
	    shift
            break
	    ;;
         -*|--*)
	    _bt_Error "unknown option: $1"
	    return 2
	    ;;
         *)
            bauTarget="$1"
	    ;;
      esac
      shift
   done

   if [ $# -gt 0 -a "$bauTarget" = "" ] ; then
      bauTarget="$1"
   fi
   if [ "$bauTarget" = "" ] ; then
      bauTarget="toplevel"
   fi

   _bt_bauEngine "${bauTarget}"
   return $?
}

# the script starts here...

main "$@"
retcode=$?

exit $retcode

#
# End of bau.sh
#
