#
cmd4.run()
{
   log.debug "cmd4-numargs: $#, cmd4-args: $*"
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
   echo "this is cmd4"
   return 0
}

cmd4.init()
{
   eventpool.subscribe "bau.help"  cmd4.run
   eventpool.subscribe "cmd4"      cmd4.run
}

cmd4.init

#
# End of test-cmd4.sh
#
