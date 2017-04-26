# http://stackoverflow.com/a/8574392
__element_in() {
    local e
    for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
    return 1
}


obtain_options() {
    local args=("$@")
    local count=${#args[@]}
    
    # No more arguments to process. We are done.
    if [[ count == 0 ]]; then
        return 0
    fi
    
    local fst=${args[0]}
    local snd=${args[1]}
    
    # -- marks the end of options.
    if [[ $fst = -- ]]; then
        non_option_arguments+=("${args[@]:1}")
        return 0
    fi
    
    if __element_in $fst "${value_options[@]}"; then
        # $fst examples:
        #     "--file" (where "--file" is in value_options)
        #     "-c" (where "-c" is in value_options)
        
        if [[ -z $snd ]]; then
            return 1
        else
            # $snd is a valid value.
            option_values[$fst]=$snd
            obtain_options "${args[@]:2}"
            return $?
        fi
    elif [[ $fst =~ ^(--.+)=(.*)$ ]] || [[ $fst =~ ^(-.)=(.*)$ ]]; then
        # $fst examples:
        #     "--file=foo.txt"
        #     "-c=something"
        #     "--file="
        #     "-c="
        
        local option=${BASH_REMATCH[1]}
        local value=${BASH_REMATCH[2]}
        
        if __element_in $option "${value_options[@]}"; then
            # $option, e.g., "--file" or "-c", is in value_options.
            if [[ -n $value ]]; then option_values[$option]=$value; fi
            obtain_options "${args[@]:1}"
            return $?
        else
            return 1
        fi
    elif [[ $fst =~ ^--(.+)$ ]]; then
        # $fst example:
        #     "--archive"
        
        local option=${BASH_REMATCH[1]}
        
        if __element_in $option "${multi_letter_count_options[@]}"; then
            (( option_counts[$option]+=1 ))
            obtain_options "${args[@]:1}"
            return $?
        else
            return 1
        fi
    elif [[ $fst = -?* ]]; then
        # $fst examples:
        #     "-a"
        #     "-avz"
        
        local i=1
        for (( i=1; i<${#fst}; i++ )); do
            local letter="${fst:$i:1}"            
            if __element_in $letter "${one_letter_count_options[@]}"; then
                (( option_counts[$letter]+=1 ))
            else
                return 1
            fi
        done
        
        obtain_options "${args[@]:1}"
        return $?
    else
        # Options are done.
        non_option_arguments+=("${args[@]}")
        return 0
    fi
    
    # Impossible.
    return 1
}
