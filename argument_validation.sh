CPH="@@"
function validate_args() { 
    #set +x1 
    local _ORIG_IFS="$IFS"

    IFS=':'
    for var_def in "$@"
    do
        local array=($var_def)
        local _length="${#array[@]}"
        local  var="${array[0]}"

        #echo "var $var length $_length"

        if [  -z "${!var}" ]; then 

            #default value 
            if (( "$_length" >= 2 )) && [[ ! -z "${array[1]}"  ]]; then            

                #echo "inside def val" 
                 
                #printf -v  "$var" -- "${array[1]}"
                #local _tmp="`eval "echo '${array[1]}'"`"
                local _tmp=`eval echo $(echo "${array[1]}" | sed -e 's/\([(){}]\)/\\\\\1/g')`
                printf -v "$var" "%s" "${_tmp//$CPH/:}" || exit_on_error "Failed to expand variable $var default value ${array[1]}"

                #echo "after default value assignment ${!var}"                
            fi 

            if [[ ! "${!var}" ]] ; then 

                    #echo "in var is still empty after default"

                    #should abort 
                     if (( "$_length" >= 4 )) ; then            
                        abort="${array[3]}" 
                    else 
                        abort="true" ; 
                    fi 

                    #echo "abort is $abort"

                    #error msg 
                    if (( "$_length" >= 3 )) ; then            
                        err_msg="${array[2]}" 
                    else 
                        err_msg="Mandatory variable $var is undefined" ;
                    fi

                    #echo "err message $err_msg"
                   
                    if [[ $abort = "true" ]] ; then 
                        exit_on_error "$err_msg - aborting!!"
                    else 
                        [[ "$err_msg" ]] && error "$err_msg" 
                    fi 

            fi # if still empty after default assignment 

        elif [[ "${!var}" =~ "\$"  ]] ; then 
            printf -v "$var" "`eval echo ${!var}`" || exit_on_error "Failed to expand variable $var = ${!var}"
        fi 

        info "Successfully validated param $var=`[[ $var == 'PSSWD' ]] && echo '************' || echo "${!var}"`"
    done

    # Check if help was requested
    if [[ ! -z $H || ! -z $HELP ]] ; then
	usage 2>/dev/null || default_usage
    	exit 0 ;
    fi
    
    IFS="$_ORIG_IFS"
   # set -x1  
}