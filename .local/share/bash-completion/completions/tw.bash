_tw() {
    local i cur prev opts cmd
    COMPREPLY=()
    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
        cur="$2"
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
    fi
    prev="$3"
    cmd=""
    opts=""

    for i in "${COMP_WORDS[@]:0:COMP_CWORD}"
    do
        case "${cmd},${i}" in
            ",$1")
                cmd="tw"
                ;;
            *)
                ;;
        esac
    done

    case "${cmd}" in
        tw)
            opts="-f -h -V --multiparts --format --sqlite-key --no-header --ignore-errors --infer-schema --infer-datetimes --separator --quote-char --widths --separator-length --no-flexible-width --truncate-ragged-lines --infer-types --no-type-inference --help --version"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 1 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --multiparts)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --format)
                    COMPREPLY=($(compgen -W "dsv csv tsv parquet jsonl json arrow fwf sqlite excel logfmt avro html markdown" -- "${cur}"))
                    return 0
                    ;;
                -f)
                    COMPREPLY=($(compgen -W "dsv csv tsv parquet jsonl json arrow fwf sqlite excel logfmt avro html markdown" -- "${cur}"))
                    return 0
                    ;;
                --sqlite-key)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --infer-schema)
                    COMPREPLY=($(compgen -W "no fast safe" -- "${cur}"))
                    return 0
                    ;;
                --separator)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --quote-char)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --widths)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --separator-length)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --infer-types)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
    esac
}

if [[ "${BASH_VERSINFO[0]}" -eq 4 && "${BASH_VERSINFO[1]}" -ge 4 || "${BASH_VERSINFO[0]}" -gt 4 ]]; then
    complete -F _tw -o nosort -o bashdefault -o default tw
else
    complete -F _tw -o bashdefault -o default tw
fi
