#!/bin/bash

#Set default values
action=$1                                 # default for case

NAMES_list=$HOME/bin/gnamelist  # non-root file with list of names

if [ -f $NAMES_list ]; then
  nl=`wc $NAMES_list | awk '{print $1}'`  
  # nl is the number of entries in list of names
fi

# list functions

# checking for an integer type value  found linuxquestion
function is_integer() {
  printf "%d" $1 > /dev/null 2>&1
  return $?
}

# checking for an integer is in range  between 1 and nl
function in_range() {
  if [ $1 -ge 1 ] && [ $1 -le $nl ] ; then
    return 0
  else
    return 1 
  fi
}

# used in show option to list NAMES_list entries and their assoc number
function list_by_number() { 
echo "List of names file " $NAMES_list "has" $nl "entries"

  if [ "$1." == '.' ]; then
    let start=1;let end=$nl;let index=1
  else
    let start=$1;let end=$start+9  # arrange for 10 lines
    if [ $end -gt $nl ]; then
      let end=$nl
    fi
    let index=$start
  fi
  echo "Range of entries from $start to $end"

  while [ $index -le $end ]; do
    thefile=`head -n$index $NAMES_list  | tail -n1`
    echo ">>"  $index  $thefile
    let index=$index+1
  done
 }

# end of functions
# start of mainline

if [ ".$1" == "." ] || [ ".$1" == ".." ]; then 
   action=help
fi
if [ "$1" == "show" ]; then
  action=show
fi
if [ ".$1" == ".0" ]; then 
  action=vimit
fi

if [ "$1" == "rep" ]; then
  action=overlay
  echo $action
fi

if [ "$1" == "add" ]; then
  action=extend
fi

if [ "$1" == "q" ]; then
     echo locate $2
     locate $2 > ~/tempname
     wc ~/tempname
     g rep ~/tempname
     action=noop
fi

case "$action" in

"noop" )
  ;;

"help" )   # provide syntax     no parms or parm1=help
  echo "  list file is $NAMES_list                 "
  echo "                                           "
  echo "     parm1  parm2                          "
  echo "  g  (none)       - show this help/syntax  "
  echo "       .          - show this help/syntax  "
  echo "       rep  file  - overlay list with file "
  echo "       add  file  - concat file to list    "
  echo "       show       - enumerat entire list   "
  echo "       show  n    - 10 entries in list     "
  echo "                     starting at n         "
  echo "        0         - vim $NAMES_list        "
  echo " ===>   n         - vim n-th entry in $NAMES_list"
  echo "        q  value  - q(uickly) locate files  "
  echo "              with value in name and put   "
  echo "              in list file                 "

  echo "  list file is $NAMES_list                 "
  echo "                                           "
  echo "                                           "
 ;;

"vimit" )
  vim $NAMES_list       # /home/$USER/bin/gnamelistM
  ;;

"show" )
  list_by_number  $2
  ;;

"overlay" )
  echo "Replacing "$NAMES_list" with "$2
  echo "cat $2 > $NAMES_list"
  cat $2 > $NAMES_list
  ;;

"extend" )
  echo "Extend "$NAMES_list" with "$2
  cat $2 >> $NAMES_list
  ;;

 * )  # edit file

if  is_integer $1; then
  if in_range $1; then
    thefile=`head -n$1 $NAMES_list  | tail -n1`
    
    # handle the ~
    if [ ${thefile:0:1} == "~" ] ; then
      tailend=${thefile:1}
      thefile=$HOME$tailend
    fi
    vim $thefile
  else
    echo $1 is NOT in RANGE  1 .. $nl
  fi
else
  echo "$1 is NOT and integer"
  echo "you hit the default - handle what is left"
  echo "how to handle  $1  is unknown "
fi
  ;;
esac
exit 0
