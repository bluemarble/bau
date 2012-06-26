#!/bin/bash

source eventpool.sh
source spinner.sh
source log.sh

_bau.engine.start_handler()
{
   log.debug "start test..."
   _spinner --start "Processing... "
}
_bau.engine.end_handler()
{
   _spinner --end "done."
}
_bau.engine.tick_handler()
{
   _spinner --next
}
_bau.engine.end_log_handler()
{
   log.debug "finished test."
}

# int
main()
{
   # wire up the event handlers

   eventpool.subscribe "bau.engine.tick"  _bau.engine.tick_handler
   eventpool.subscribe "bau.engine.start" _bau.engine.start_handler
   eventpool.subscribe "bau.engine.end"   _bau.engine.end_handler
   eventpool.subscribe "bau.engine.end"   _bau.engine.end_log_handler

   # do something, firing events as we go

   eventpool.fireEvent "bau.engine.start"
   local j=0
   local limit=100
   if [ "$1" != "" ] ; then
      limit="$1"
   fi
   while [ $j -lt $limit ] ; do
      eventpool.fireEvent "bau.engine.tick"
      let j=j+1
   done
   eventpool.fireEvent "bau.engine.end"

   return 0
}

main $*
exit $?
