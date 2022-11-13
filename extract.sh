#!/usr/bin/env bash
set -e -o pipefail -o errtrace
err_holder() {
    num="$1"
    echo "[ERROR] Oops, an error occurred. [L${num}]"
    printf '\a'
}
trap 'err_holder $LINENO' ERR

cd "$(dirname "$0")"

echo "[INFO] *****$(basename "$0") START*****"
echo "[INFO] start time: $(date "+%Y/%m/%d %T")"
start_time=$(date +%s)

author_name=$1 # required

if [ -z "${author_name}" ]; then
    echo "[ERROR] no argument specified"
    exit 1
fi

# Functions

main_func() {
    source_path=$1
    if [ ! -f "${source_path}" ]; then
        echo "[ERROR] '${source_path}' does not exist"
        exit 1
    fi
    if [ ! -d processing ]; then
        mkdir processing
    fi
    if [ ! -d finished ]; then
        mkdir finished
    fi

    file_name=$(basename "${source_path}" .txt)

    extracted=processing/"extracted_${file_name}.tsv"

    ## extract data
    if ! grep " / ${author_name} 著" "${source_path}" | grep BK | grep -v "${author_name} 著 ;" >"${extracted}"; then
        echo "[INFO] there is no data" && return
    fi

    dest_path=finished/"${file_name}_${author_name}.tsv"
    echo "[INFO] Destination: $(pwd)/${dest_path}"

    tab=\\t

    ## add header
    echo -e "TITLE${tab}SUB_TITLE${tab}EDITION${tab}AUTHOR${tab}PUBLISHER${tab}PUBLISHED_DATE${tab}ISBN_CODE" >"${dest_path}"

    while IFS= read -r row; do

        ## process data
        regexp="\(^.*\)\( : \)\(.*\)\( : \)\(.*\)\( \/ \)\(.*著\)\(\.*$\)"
        correction_val=2
        if [ "$(echo "${row}" | awk -F '\t' '{print $6}' | sed "s/${regexp}/\4/")" != " : " ]; then
            regexp="\(^.*\)\( : \)\(.*\)\( \/ \)\(.*著\)\(\.*$\)"
            correction_val=0
        fi
        if [ "$(echo "${row}" | awk -F '\t' '{print $6}' | sed "s/${regexp}/\2/")" != " : " ]; then
            correction_val=0
            regexp="\(^.*\)\(.*\)\(.*\)\( \/ \)\(.*著\)\(\.*$\)"
        fi

        ### set title
        title=$(echo "${row}" | awk -F '\t' '{print $6}' | sed "s/${regexp}/\1/")

        ### set sub_title
        if [ ${correction_val} = 0 ]; then
            sub_title=$(echo "${row}" | awk -F '\t' '{print $6}' | sed "s/${regexp}/\3/")
        elif [ ${correction_val} = 2 ]; then
            sub_title=$(echo "${row}" | awk -F '\t' '{print $6}' | sed "s/${regexp}/\3\4\5/")
        fi

        ### set edition
        edition=$(echo "${row}" | awk -F '\t' '{print $7}')

        ### set author
        author=$(echo "${row}" | awk -F '\t' '{print $6}' | sed "s/${regexp}/\\$((5 + correction_val))/")

        regexp="\(^.*\)\( : \)\(.*\)\(, \)\(.*\)\(.*$\)"

        ### set publisher
        publisher=$(echo "${row}" | awk -F '\t' '{print $9}' | sed "s/${regexp}/\3/")

        ### set published_date
        published_date=$(echo "${row}" | awk -F '\t' '{print $9}' | sed "s/${regexp}/\5/")

        ### set isbn_code
        isbn_code=$(echo "${row}" | awk -F '\t' '{print $4}')

        ## add row
        echo -e "${title}${tab}${sub_title}${tab}${edition}${tab}${author}${tab}${publisher}${tab}${published_date}${tab}${isbn_code}" >>"${dest_path}"

    done <"${extracted}"

    ## change empty to hyphen
    sed -e 's/\t\t/\t-\t/g;s/\t-\t\t/\t-\t-\t/g' <"${dest_path}" >tmpfile && mv tmpfile "${dest_path}"
}

# Actions

## prior confirmation

if [ ! -d source ]; then
    echo "[ERROR] '$(pwd)/source' does not exist"
    exit 1
fi

## execution

files_array=$(find ./source -maxdepth 1 -type f)

for source_path in ${files_array}; do
    echo "[INFO][START] Extract ${author_name} BOOKS"
    file_name=$(basename "${source_path}")
    echo "[INFO] Source: $(pwd)/source/${file_name}"
    main_func "${source_path}"
    echo "[INFO][END] Extract ${author_name} BOOKS"
done

echo "[INFO] end time: $(date "+%Y/%m/%d %T")"
echo "[INFO] execute time: $(($(date +%s) - "${start_time}")) sec"
echo "[INFO] *****$(basename "$0") END*****"
