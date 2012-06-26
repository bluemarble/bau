#
cmd1.run()
{
   log.debug "cmd1-numargs: $#, cmd1-args: $*"
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
   echo "this is cmd1"
   return 0
}

cmd1.init()
{
   eventpool.subscribe "bau.help"  cmd1.run
   eventpool.subscribe "cmd1"      cmd1.run

   # a command can have aliases
   eventpool.subscribe "build"     cmd1.run
   eventpool.subscribe "make"      cmd1.run
}

cmd1.init

#
# End of test-cmd1.sh
#
