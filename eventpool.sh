# private static 
__eventpool_make_varname()
{
   # change '.' to '_' in the event-name
   local str="${1}"
   while true ; do
      case "$str" in
      *.*) str="${str%.*}_${str##*.}" ;;
      *)   break ;;
      esac
   done
   local varName="__eventpool_subscriber__${str}"
   eval "${2}=${varName}"
}

# public int
eventpool.fireEvent()
{
   log.debug "FireEvent-args: $*"

   # change '.' to '_' in the event-name
   local str="${1}"
   while true ; do
      case "$str" in
      *.*) str="${str%.*}_${str##*.}" ;;
      *)   break ;;
      esac
   done
   local varName="__eventpool_subscriber__${str}"

   # I'm going to get rid of the event name... maybe a bad idea?  the delegates might want to know the eventName...
   shift

   local delegate
   for delegate in $( eval echo \${${varName}[@]} )
   do
      ${delegate} $*
   done

   return 0
}

# format:  __eventpoolSubscriber__<event-name>

# public int
eventpool.subscribe()
{
   # change '.' to '_' in the event-name
   local str="${1}"
   while true ; do
      case "$str" in
      *.*) str="${str%.*}_${str##*.}" ;;
      *)   break ;;
      esac
   done
   local varName="__eventpool_subscriber__${str}"

   eval "${varName}=( \${${varName}[@]} ${2} )"
}

eventpool.publish()
{
   : #todo
}
