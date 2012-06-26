# information about this tool
#_cmdname="$(basename $0)"
_cmdname="bau"
_cmdversion="0.1"

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
