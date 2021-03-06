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
Pretend_p=f
Rebuildall_p=f
Dump_p=f

_bt_treeRootDir=""

# start hack -- include external bt functions
_spinner_nextChar='|'
_spinner_active_p=f
_spinner()
{
   while [ $# -gt 0 ] ; do
      case "$1" in
      --start)
	 printf >&2 "$2  "
         _spinner_nextChar='|'
         _spinner_active_p=t
	 shift
         ;;
      --end)
	 printf >&2 '\b'"$2"'\n'
         _spinner_nextChar='|'
	 _spinner_active_p=f
	 shift
         ;;
      --next)
	 if [ $_spinner_active_p = f ] ; then
	    break
	 fi
         printf >&2 '\b'"${_spinner_nextChar}"
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

# static int
__ftw_internal()
{
   local dir="$1"

   local callback="true"
   if [ "$2" != "" ] ; then
      callback="$2"
   fi

   for entry in "${dir}"/* ; do
      eval "${callback} ${entry}"
      if [ -d "${entry}" ] ; then
         __ftw_internal "${entry}" "${callback}"
      fi
   done

   return 0
}

##
 # _ftw() walks a filesystem, invoking a user-supplied callback for
 # each file or directory found.
 ##

# int
_ftw()
{
   local fname="ftw"

   local startDir="."
   local callback=""
   local breadthFirst_p=t

   while [ $# -gt 0 ] ; do
      case "$1" in
         --depthfirst)
            breadthFirst_p=f
	    ;;
         --breadthfirst)
            breadthFirst_p=t
	    ;;
         --callback)
	    callback="$2"
	    shift
	    ;;
	 --help)
	    printf "Usage: ${fname} [ --callback expression ] [ --depthfirst | --breadthfirst ] [ dir ]\n"
	    return 0
	    ;;
	 *)
	    break
	    ;;
      esac
      shift
   done

   if [ $# -gt 0 ] ; then
      startDir="$1"
   fi

   if [ ! -d "${startDir}" ] ; then
      echo >&2 "${fname}: ${startDir} is not a directory"
      return 1
   fi

   __ftw_internal "${startDir}" "${callback}"

   return $?
}
# end hack

# sysconf definitions
E=.exe
O=.o
LIB=.lib
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

   _bt_Error "no ${bauTreeconf} found"
   return 1
}

_bt_ProcessTreeVrs()
{
   local treevrs="$1"

   #if [ ! -f "${treevrs}" ] ; then
      #_bt_Error "unable to process \"${treevrs}\""
      #return 1
   #fi

   source "${treevrs}"

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
   return $__bt_lastError
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

   if [ "${__bt_currentBaufile}" != "" ] ; then
      printf >&2 "%s: error: %s: %s\n"  "${_cmdname}" "${__bt_currentBaufile}" "$*"
   else
      printf >&2 "%s: error: %s\n" "${_cmdname}" "$*"
   fi

   _bt_LastError_set 1
}

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
   bauEmit "\n# This is the epilog.\n"
   return 0
}

# build tools

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

#
# bau itself -- bau-engine, mainline, command-line parsing, etc.
#

_bt_bauEngine()
{
   local target="$1"

   _spinner --start "Processing ..."

   _bt_Treevrs="$( _bt_FindTreeVrs --callback "_spinner --next" )"
   if [ $? -ne 0 ] ; then
      _bt_Error "unable to continue, will exit."
      return 1
   fi
   _spinner --next

   _bt_treeRootDir="$(dirname "${_bt_Treevrs}")" && _spinner --next

   _bt_ProcessTreeVrs "${_bt_Treevrs}" && _spinner --next

   bauCurrDir="$PWD"
   bauProlog
   bauEmit "toplevel : targets\n"
   _spinner --next

   #xyz="$( ${Find} "${_bt_treeRootDir}" -type f -name '[Bb]aufile' )"
   bauFiles="$( ${Find} . -type f -name '[Bb]aufile' )"
   _spinner --next
   for baufile in $bauFiles ; do
      bauEmit "# process: $baufile\n"

      bauRelDir="$(dirname "${baufile}")"
      bauIncludeDirs=""
      targets=""

      _spinner --next
      __bt_currentBaufile="${baufile}"
      source "${baufile}"
      __bt_currentBaufile=""

      if [ "$targets" != "" ] ; then
         bauEmit "targets : ${targets}\n"
      fi
   done
   _spinner --next

   bauEpilog
   _spinner --end "done."

   makeOpts=""
   if [ "${Pretend_p}" = t ] ; then
      makeOpts="-n"
   fi
   if [ "${Rebuildall_p}" = t ] ; then
      makeOpts="${makeOpts} -k"
   fi
   "${Make}" -f "${bauMkfile}" ${makeOpts} "${target}"
   _bt_LastError_set $?

   if [ "${Dump_p}" = t ] ; then
      cat "${bauMkfile}"
   fi
   if [ "${Keep_p}" != t ] ; then
      rm -f "${bauMkfile}"
   fi

   return $(_bt_LastError_get)
}

# static int
__ftw_cb_LoadPlugins()
{
   case "$1" in
   *.plugin)
      source "$1"
      ;;
   *)
      ;;
   esac

   return 0
}

version()
{
   printf 'Bluemarble %s %s\n' "${_cmdname}" "${_cmdversion}"
   printf 'Copyright (c) 2005 Blue Marble Systems.\n'
   return 0
}

usage() 
{
   echo "
Usage: ${_cmdname} [options] [target]

Options:
   --pretend
   --rebuildall
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
   local target=""

   # parse the command line:
   while [ $# -gt 0 ] ; do
      case "$1" in
         --pretend)
	    Pretend_p=t
	    ;;
         --rebuildall)
	    Rebuildall_p=t
	    ;;
	 --keep)
	    Keep_p=t
	    ;;
	 --dump)
	    Dump_p=t
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
            target="$1"
	    ;;
      esac
      shift
   done

   # figure out what the target of the build will be:
   if [ $# -gt 0 -a "$target" = "" ] ; then
      target="$1"
   fi
   if [ "$target" = "" ] ; then
      target="toplevel"
   fi

   # load plug-ins:
   _ftw --breadthfirst \
        --callback __ftw_cb_LoadPlugins \
        /usr/local/bluemarble/lib/bau

   # fire up the build engine:
   _bt_bauEngine "${target}"
   return $?
}

main "$@"
exit $?

#
# End of bau.sh
#
