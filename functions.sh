function compare()
{
  if [[ "$1" -gt "$2" ]] ; then 
    return 1
  fi
  if [[ "$1" -lt "$2" ]] ; then 
    return 2
  fi
  return 0
}

function compare_version()
{
  major1=`expr match ".$1" '.*\.\([0-9]*\)\.[0-9]*\.[0-9]*-[0-9]*'`
  major2=`expr match ".$2" '.*\.\([0-9]*\)\.[0-9]*\.[0-9]*-[0-9]*'`
  middle1=`expr match ".$1" '.*\.\([0-9]*\)\.[0-9]*-[0-9]*'`
  middle2=`expr match ".$2" '.*\.\([0-9]*\)\.[0-9]*-[0-9]*'`
  minor1=`expr match ".$1" '.*\.\([0-9]*\)-[0-9]*'`
  minor2=`expr match ".$2" '.*\.\([0-9]*\)-[0-9]*'`
  release1=`expr match ".$1" '.*-\([0-9]*$\)'`
  release2=`expr match ".$2" '.*-\([0-9]*$\)'`
  
  compare $major1 $major2
  result=$?
  if [[ $result -ne 0 ]] ; then
    return $result 
  fi
  compare $middle1 $middle2
  result=$?
  if [[ $result -ne 0 ]] ; then
    return $result 
  fi
  compare $minor1 $minor2
  result=$?
  if [[ $result -ne 0 ]] ; then
    return $result 
  fi
  compare "$release1" "$release2"
  result=$?
  if [[ $result -ne 0 ]] ; then
    return $result 
  fi
  return 0
}

ask_user_y_n() 
{
  default_answer=${2:-n}
  
  if [[ ${FORCE_ANSWER:-no} == "no" ]] ; then 
    answer_ok=0
    while [ 1 ]; do 
      answer="y"     
      if [ "$default_answer" == n ] ;
      then 
        echo "$1 [y/N]: "
        read answer
      else 
        echo "$1 [Y/n]: "
        read answer
      fi
      
      if [ "${answer:0:1}" == Y ]; 
      then 
        return 1
      fi
      
      if [ "${answer:0:1}" == y ]; 
      then 
        return 1
      fi
      
      if [ "${answer:0:1}" == N ];
      then 
        return 0
      fi
      
      if [ "${answer:0:1}" == n ];
      then 
        return 0
      fi

      if [ ! $answer ] ; then 
        if [ "$default_answer" == n ];
        then 
          return 0
        else
          return 1
        fi
      fi

    done
  else 
    if [ "$FORCE_YES" == "yes" ];
    then 
      echo "$1 [Y/n]:Y "
      return 1
    fi 
    
    if [ "$default_answer" == n ];
    then 
      echo "$1 [y/N]:N "
      return 0
    else
      echo "$1 [Y/n]:Y "
      return 1
    fi
  fi
}

execute_command()
{
  if [ $# -eq 0 ];
  then   
    error_exit "ERROR \"execute_command\" failed: no arguments given."
  fi

  local command=$1
  echo "*** $command " | tee -a $LOGFILE
  if [ "$VERBOSE" == "yes" ] ; then 
     eval $command 2>&1 | tee -a $LOGFILE
    OK=${PIPESTATUS[0]}
  else
    eval $command >> $LOGFILE 2>&1
    OK=${PIPESTATUS[0]}
  fi
  if [ $OK -ne 0 ];
  then 
    error_exit "ERROR \"$command\" failed"
  fi
}

check_and_make_folder()
{
  if [ $# -ne 2 ];
  then   
    error_exit "ERROR \"check_and_make_folder\" failed: wrong number of arguments given."
  fi
  local path=$1
  local make_folders=$2
  if [ ! -d "$path" ] ; 
  then
    echo "No folder \"$path\" found!"
    if [ $make_folders == "yes" ] ; then
      ask_user_y_n "Folder $path does not exists create?" y
      if [ $? -eq 1 ] ; then 
        echo Creating folder "$path" | tee -a $LOGFILE
        mkdir -p $path
        return 0
      fi
    else 
      echo "Use option -m to automatically create missing folders." | tee -a $LOGFILE 
    fi
    return 1;
  fi
  return 0
}
