#
cmd3.run()
{
   log.debug "cmd3-numargs: $#, cmd3-args: $*"
   log.debug "arg0=$0"

   while [ $# -gt 0 ] ; do
      log.debug "arg1=$1"
      case "$1" in
      --oneliner)
         echo "make, build    Does a make or build thing."
         return 0
	 ;;
      *) break ;;
      esac
      shift
   done
   echo "this is cmd3"
   return 0
}

cmd3.init()
{
   eventpool.subscribe "bau.help"  cmd3.run
   eventpool.subscribe "cmd3"      cmd3.run
}

cmd3.init

#
# End of test-cmd3.sh
#
