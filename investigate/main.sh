#!/bin/bash
#
# This is an example of how to use _ftw to enumerate a set of plugin files.
# The techniques avoids subshells (forking) and pipelines, using shell builtins
# instead of stuff like the following:
#
# for file in *.plug ; do
#   echo "about to process $file"
#   source $file
# done

source "../../ftw/ftw.shf"
source "../../spinner/spinner.shf"

__ftw_cb_ProcessFile()
{
   case "$1" in
   *.plug)
      #echo "about to process $1"
      source "$1"
      _spinner --next
      ;;
   *)
      ;;
   esac
   return 0
}

main()
{
   _spinner --start "Processing ..."

   _ftw \
      --breadthfirst \
      --callback __ftw_cb_ProcessFile \
      $PWD

   _spinner --end "done."

   plugin
}

main

plugin
plugin
plugin

#
#
#
