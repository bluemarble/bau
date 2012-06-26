#!/bin/bash
#
# bt-makescript-helper.sh --
#

main()
{
   local outfile=""
   local skeleton=""
   local scriptFrag=""

   while [ $# -gt 0 ] ; do
      case "$1" in
	 --out)
	    outfile="$2"
	    shift
	    ;;
	 --skel*)
	    skeleton="$2"
	    shift
	    ;;
         *)
	    scriptFrag="$1"
	    break
	    ;;
      esac
      shift
   done

   if [ "${outfile}" = "" ] ; then
      : #echo >&2 "error: "
   fi
   if [ "${scriptFrag}" = "" ] ; then
      echo >&2 "error: no script skeleton specified."
      return 1
   fi

   local script="$(basename "${scriptFrag}" .shf)"
   local scriptFragEntry="_${script}"
   local scriptOut="${script}"

   eval '
      cat <<EOF
'"$(cat "${skeleton}")"'
EOF'

   return 0
}

main "$@"
exit $?

#
# End of bt-makescript-helper.sh
#
