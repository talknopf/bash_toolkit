function parse_args() { 

    info "about to parse args: $@"

    while [[ $# -ge 1 ]]
    do
        key="$1"
        shift
        
        case $key in  
           --*|––*)
            var_name="${key:2}" ; 
            ;;
           -*|–*)
            var_name="${key:1}" ;            
            ;; 
        esac

        local _val="$1"
        
        if [[ "${_val:0:1}" == '-' ]] || [[ "${_val:0:1}" == '–' ]] ; then 
           _val='true'
        elif [[ -z $_val ]] && [[ $# -eq 0 ]] ; then 
            _val='true'
        else 
            shift 
        fi 

        info "-$var_name=$_val"
               
        if [[ ! "$var_name" =~ "__" ]] ; then 
            var_name=`echo -e "$var_name" | perl -ne 'print uc'`
        fi 

        if [  -z "${!var_name}" ] || [ "$_POM" == 'true' ] ; then  
            
            if [ "${var_name:0:1}" == '@' ] ; then 
                eval "${var_name:1}+=("$_val")"
            else 
                printf -v "$var_name" "$_val" || exit_on_error "Failed to parse argument $var_name with value $_val"
            fi 

        else 
            warn "$var_name was already defined: ${!var_name}, discarding value '$_val'"
        fi 
    
    done
}
