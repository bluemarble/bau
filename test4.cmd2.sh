#
cmd2.run()
{
   log.debug "cmd2-numargs: $#, cmd2-args: $*"
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
   echo "this is cmd2"
   return 0
}

cmd2.init()
{
   eventpool.subscribe "bau.help"  cmd2.run
   eventpool.subscribe "cmd2"      cmd2.run
}

cmd2.init

#
# End of test-cmd2.sh
#
