#!/bin/bash
#
# Work all downloaded web files to archive format.
# Extract all assets to prs file to be archived.
#
# Outputs:
# prs-out.txt - list of download assets sources and output location
# modifies the files in downloaded web pages
#
# Usage:
# ./prs.sh download/www.helswingi.fi
#

workdir=$(pwd)
urlfile="$workdir/prs-out.txt"

old_domain="www.helswingi.fi"
new_domain="2022.helswingi.fi"

function tester {
    urlfile="$workdir/prs-test.txt"
    local url="//static1.squarespace.com/static/5cd3e61db91449614c565754/t/5ce66ad1104c7bda1750dbb5/1582726096611/?format=1500w"
    local path=$(urltolocalpath $url)

    echo $url |sed "s#$url#$path#g"
}


function sortuniq {
    local file=$1
    sortedurls=$(sort "$file" |uniq)
    echo -e "$sortedurls" > "$file"
}

function urltolocalpath {
    local url=$1
    sedrq='s#\/\?#?#g'
    sedrpath='s#(http:|https:|:|)\/\/([^\.]+\.squarespace[^\/]+)(\/.*)(\/.*)(\/[^\s"]*)#/ext-assets/\2\4\5#g'
    sedrhs='s#[\?\&\=]#-#g'

    res=$(echo "$url" |sed -E $sedrq |sed -E $sedrpath |sed -E $sedrhs)
    echo $res
}

function getfileurls {
    local file=$1
    local tmp="$workdir/urls.tmp.txt" # where to write extracted urls
    cat "$file" |grep -Eo '(http(s|):|:|)//[^\.]+\.squarespace[^\"]+' > "$tmp"
    sortuniq "$tmp"

    # return
    cat "$tmp"
}

function workfile {
    local file=$1
    echo " working on: $file"

    # share thumb
    local old_thum="https://images.squarespace-cdn.com"
    local new_thum="https://2022.helswingi.fi/ext-assets/"
    sed -Ei "s#$old_thum#$new_thum#g" "$file"

    # preconnect
    local old_con="http://static1.squarespace.com/static/5cd3e61db91449614c565754/t/63f881a397059c370eab0b54/1677230500028/save-the-date-2023.png?format=1500w"
    local new_thum="https://images.squarespace-cdn.com/content/v1/5cd3e61db91449614c565754/1655755916514-VGP4DJISPJJP7JUQ61SN/helswingi-cover-2022-web.jpg?format=1500w"
    sed -Ei "s#$old_thum#$new_thum#g" "$file"

    # ext urls
    local urls=$(getfileurls "$file")
    while IFS= read -r url
    do
        local path=$(urltolocalpath "$url")
        sed -i "s#\"$url\"#\"$path\"#g" "$file"
        echo "$url|$path" >> "$urlfile"
    done <<< "$urls"
    # domain
    sed -Ei "s#$old_domain#$new_domain#g" "$file"
    # title
    sed -Ei "s#Helswingi 2023#Helswingi 2022#g" "$file"
}

function workfolder {
    local dir=$1 # current folder

    pushd "$PWD" > /dev/null
    cd "$dir"
    echo "=====^ $PWD ====="
    # recursively loop all folders
    for i in $( ls ) ; do
        if [ -d "$i" ] ; then
            workfolder "$i"
        fi
    done
    # handle file
    for i in $( ls |grep .html ) ; do
        workfile "$PWD/$i"
    done
    popd > /dev/null
    echo "=====v $PWD ====="
}

function dowork {
    local dir=$1 # current folder
    local op=$2

    echo "" > "$urlfile"
    workfolder "$dir" # extract all urls
    sortuniq "$urlfile"
}


# tester
# exit 0

dowork $1 $2







# function workfolder {
#     local dir=$1 # current folder
#     local updir=$2 # prefix upfolders
#     local urloutfile=$3 # where to write extracted urls
# 
#     pushd "$PWD" > /dev/null
#     cd "$dir"
#     echo "$urloutfile"
#     echo "=====^ $PWD ====="
#     for i in $( ls ) ; do
#         if [ -d "$i" ] ; then
#             workfolder "$i" "..\\/$updir" "$urloutfile"
#         fi
#     done
#     for i in $( ls |grep .html ) ; do
#         echo " working on: $PWD/$i"
#         cat $i |grep -Eo '(http(s|):|:|)//[^\.]+\.squarespace[^\"]+' >> $urloutfile
#         sed -Ei 's#(http:|https:|:|)//([^\.]+\.squarespace[^\"]+)#ext-assets/\2#g' $i
#         # sed -Ei 's/data-src="([^\"]+)"/src="\1" data-src="\1"/g' $i
# 
#     done
#     popd > /dev/null
#     echo "=====v $PWD ====="
# }
