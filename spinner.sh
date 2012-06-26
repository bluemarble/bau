__spinner_nextChar='|'
_spinner_active_p=f

_spinner()
{
   while [ $# -gt 0 ] ; do
      case "$1" in
      --start)
	 printf >&2 "$2 "
         __spinner_nextChar='|'
         _spinner_active_p=t
	 shift
         ;;
      --end)
	 printf >&2 '\b'"$2"'\n'
         __spinner_nextChar='|'
	 _spinner_active_p=f
	 shift
         ;;
      --next)
	 if [ $_spinner_active_p = f ] ; then
	    break
	 fi
         printf >&2 '\b'"${__spinner_nextChar}"
         case "$__spinner_nextChar" in
	    '|') __spinner_nextChar='/' ;;
	    '/') __spinner_nextChar='-' ;;
	    '-') __spinner_nextChar='\' ;;
	    '\') __spinner_nextChar='|' ;;
	 esac
         ;;
      --chars)
         # silently ignore -- this option not currently implemented
         ;;
      --)
	 shift
	 break
         ;;
      *)
         break
	 ;;
      esac
      shift
   done

   return 0
}
