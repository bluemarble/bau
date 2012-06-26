#!/bin/bash

source import.sh
source eventpool.sh
source log.sh

#import eventpool.sh
#import log.sh

import test4.cmd1
import test4.cmd2
import test4.cmd3
import test4.cmd4

# int
main()
{
   while [ $# -gt 0 ] ; do
      case "$1" in
      --help|-h)
         eventpool.fireEvent "bau.help" --oneliner
	 return 0
         ;;
      --debug)
         log.setLogLevel DEBUG
	 ;;
      -*)
	 echo >&2 "error: unknown option $1"
	 return 1
         ;;
      *)
         break ;;
      esac
      shift
   done

   # in a real program, we'd do the hard work here...
   cmdToRun="$1"
   shift
   eventpool.fireEvent "${cmdToRun}" $@

   return 0
}

main $@
exit $?
