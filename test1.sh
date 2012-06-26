#!/bin/bash

source eventpool.sh
source log.sh

subscriber1()
{
   echo "subscriber1 got event: $*"
}

subscriber2()
{
   echo "subscriber2 got event: $*"
}

finished()
{
   echo "Got event notifying that we are finished"
}

# int
main()
{
   eventpool.subscribe "event.X" subscriber1
   eventpool.subscribe "event.X" subscriber2
   eventpool.subscribe "app.finished" finished

   local vnam
   _eventpool_make_varname sys.exception.debug vnam
   echo vnam=${vnam}

   local i=0
   while [ $i -lt 4 ] ; do
      eventpool.fireEvent "event.X" $i
      let i=i+1
   done

   eventpool.fireEvent "app.finished"
   eventpool.fireEvent "nosubscribers"

   return 0
}

main $*
exit $?
