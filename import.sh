#
# import - import external packages of shell functions
#


# usage: import [-iqv] package-name

import()
{
   local fname="import"
   local msgFmt='%s: %s: %s\n'

   local module
   local quiet=t
   local ignore=f
   local verbose=f

   while [ $# -gt 0 ] ; do
   case "$1" in
      -i) ignore=t ;;
      -q) quiet=t ;;
      -v) verbose=t ;;
      *)  break ;;
   esac
   shift
   done

   module="$1"
   if [ -z "$module" ] ; then
      printf >&2 "${msgFmt}" ${fname} error "no module specified"
      return 1
   fi

   for path in \
      /usr/local/bluemarble/lib \
      /usr/local/bluemarble/lib/bash \
      .
   do
      basenam="${path}/${module}"
      #test -f ${basenam}.shf && printf "${msgFmt}" ${fname} debug "found ${basenam}.shf" && break
      #test -f ${basenam}.sh  && printf "${msgFmt}" ${fname} debug "found ${basenam}.sh"  && break
      #test -f ${basenam}.sh  && printf "${msgFmt}" ${fname} debug "found ${basenam}.bash"  && break
      #test -f ${basenam}.shf && source "${basenam}.shf" && return 0
      if [ -f ${basenam}.shf ] ; then
         test $verbose = 't' && printf >&2 "${msgFmt}" ${fname} debug "sourcing ${basenam}.shf"
         source "${basenam}.shf" 
         return 0
      fi
      test -f ${basenam}.sh  && source "${basenam}.sh"  && return 0
      test -f ${basenam}.sh  && source "${basenam}.bash" && return 0
   done

   printf >&2 "${msgFmt}" ${fname} error "no module called ${module} found"

   if [ $ignore = t ] ; then 
      return 1
   fi

   #die
   exit 1
}

#
# End of import.shf
#
