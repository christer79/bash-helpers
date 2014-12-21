#!/bin/bash
START_TIME=$(date +%s%N)
 
#Set this to yes for debugung output
DEBUG="yes"
NR_ARGUMENTS_REQURED=1
NR_ARGUMENTS_MAX=1

#Uncomment this to print each command
#set -o xtrace 
#The following make the script exit if you try to se an unitialised variable 
set -u 

function log_error
{
  echo -n $(date) 1>&2
  echo " ERROR: $1" 1>&2
}

function error_exit
{
  END_TIME=$(date +%s%N)
  echo "Execution ended with error after: "$(($(($END_TIME - $START_TIME))/1000000))" ms" 1>&2 
  exit 1
}

# PRINT USAGE 
function usage
{
  echo "Usage: "
  echo "  $0 [OPTIONS] ARG1 ARG2"
  echo "Does this with this and that"
  echo 
  echo "Options:"
  echo "  -v            : Verbose output"
  echo "  -L <log-file> : set a log file for output"
  echo 
  echo "A more detailed description"
  echo "of what the script does."
  exit 1
}

# SIGNAL CATCHER 
function exit_catcher
{
  END_TIME=$(date +%s%N)
  echo "Execution took: "$(($(($END_TIME - $START_TIME))/1000000))" ms";
}
trap exit_catcher EXIT

function interrupt_catcher
{
  echo "Ctrl+C/SIGINT catched exiting"; 1>&2
  # Do clean up here 
  exit 1
}
trap interrupt_catcher INT
#trap '' INT # To remove the trap

function sigterm_catcher
{
  echo "SIGTERM catched exiting"; 1>&2
  # Do clean up here 
  exit 1
}
trap sigterm_catcher TERM
#trap '' INT # To remove the trap

function sigalrm_cathcer
{
  echo "SIGALRM - catched exiting" 1>&2
  # Do clean up here 
  exit 1
}
trap sigalrm_cathcer SIGALRM
#Uncommet to set a maximum time the script is allowed to run.
#(sleep 3; kill -s SIGALRM $$)

#CHECK OPTIONS 
#Set default values 
LOGFILE="/tmp/"
VERBOSE="no"
FORCE_ANSWERS="no"
#Get options
while getopts "vL:h" opt; do
  case $opt in
    v) [[ $DEBUG == "yes" ]] && echo "-v was specified" 
       VERBOSE="yes" ;;
    L) [[ $DEBUG == "yes" ]] &&  echo "arg given to L is $OPTARG" 
       LOGFILE=$OPTARG ;;
    f) [[ $DEBUG == "yes" ]] && echo "-f was specified" 
       FORCE_ANSWERS="yes" ;;
    h) usage ;;
   \?) usage ;;
  esac
done

# CHECK ARUMENTS 
shift $((OPTIND-1))
[[ $DEBUG == "yes" ]] && echo "Command line arguments: $@"
if [[ $# < $NR_ARGUMENTS_REQURED ]] ; then 
  log_error "Too few arguments."
  usage
fi
if [[ $# > $NR_ARGUMENTS_MAX ]] ; then 
  log_error "Too many arguments."
  usage
fi

ARG1=$1

#Example
#(sleep 22; kill -s SIGALRM $$)
for count in 1 2; do
  echo -n "."
  sleep 1
done 

