#!/bin/bash
TIME_NOW="$(date +%F_%H_%M_%S)"

[[ ! "$OPERATION_TYPE_PREFIX" ]] && OPERATION_TYPE_PREFIX=${0}
[[ ! "$ROOT_DIR_HOME" ]] &&  ROOT_DIR_HOME=/tmp
[[ ! "$ROOT_DIR" ]] && DATE_SUFFIX="_$(date +%F_%H_%M_%S)" && ROOT_DIR="$ROOT_DIR_HOME/$OPERATION_TYPE_PREFIX$DATE_SUFFIX"

LOGS_DIR="$ROOT_DIR/logs" ;
mkdir -p "$LOGS_DIR" 

[[ ! "$LOG_FILE" ]] && LOG_FILE="$LOGS_DIR/$OPERATION_TYPE_PREFIX$TIME_NOW.log"

echo "Log file: $LOG_FILE"

exec 2> >(tee -a "$LOG_FILE") 

_SYS_FUNC_NAMES=',get_func_name,log,warn,info,error,exit_on_error,validate_args,_redirect_2_log,redirect_2_log,'    
HOSTNAME_PREFIX=[`hostname`]

function get_func_name() {
    set +x 
    result="unknwon"
    for func_name in "${FUNCNAME[@]}" ; do 
        
       if [[  $_SYS_FUNC_NAMES != *"$func_name"* ]] ; then 
             
          result="$func_name" ; 
          break ; 
          
       fi
    done ; 

    echo "$result"
    set -x
}

function redirect_2_log() {

    while read IN ; do 
        bash_log REMOTE_STDOUT "$orange" ">>STDIN Redirect>> $IN"
    done 
}

function bash_log() { 
    local msg="$(date +%d-%m-%Y_%H-%M-%S) $HOSTNAME_PREFIX [$(get_func_name)] $1 $3"  
    if [ $1 == "REMOTE_STDOUT" ]; then
        [[ "$NOISE" != 'true' ]] || echo -e "$2$msg${NC}" 
        echo -e "Remote STDOUT: $msg" >> "$LOG_FILE"
    else
        echo -e "$2$msg${NC}" 
        echo -e "$msg" >> "$LOG_FILE"
    fi 
}

info() {
    bash_log INFO "$green" "$*"
}

warn() {
    bash_log WARN "$cyan" "$*"
}

error() {
    bash_log ERROR "$red" "$*"
}

function package_workspace() { 
    cd $ROOT_DIR ; bash -c "tar cvfz $1 `ls -1 $ROOT_DIR |grep -v git | xargs`"
    error "an Error had occurred check logs `[[ $TGZ_PATH ]] && echo "(artifact $TGZ_PATH)"`!"
}

function exit_on_error() {

    local PACKAGED_WORKSPACE_TAR_NAME="$ROOT_DIR/$(basename $ROOT_DIR).tar.gz"
    ABORT_CAUSE="$1`[[ $ABORT_CAUSE ]] && echo -e "\n- $ABORT_CAUSE"`"
    
    error "$1."
    error "For more information check log file $LOG_FILE.\nWorkspace & logs were conveniently packaged into $PACKAGED_WORKSPACE_TAR_NAME (Artifact $TGZ_PATH)"

    package_workspace $PACKAGED_WORKSPACE_TAR_NAME
    
    local exit_code=${2:-1}
    error "Exit code is $exit_code"
    exit $exit_code;
}