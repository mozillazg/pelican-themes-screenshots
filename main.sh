#!/usr/bin/env bash

current_dir=$PWD

extra_repos='https://github.com/duilio/pelican-octopress-theme/'

function clone_themes() {
    rm -rf $current_dir/public/data/*/
    cd $current_dir/public/data
    git clone --depth=1 --recursive git://github.com/getpelican/pelican-themes
}

function clone_extra_themes() {
    cd $current_dir/public/data
    for x in ${extra_repos[*]}; do
        git clone "$x" --depth=1
    done
}

function fix_git_repo() {
    cd $current_dir/public/data/pelican-themes
    set -e
    rm -rf .git
    git init

    git config -f .gitmodules --get-regexp '^submodule\..*\.path$' > tempfile

    while read -u 3 path_key path
    do
        url_key=$(echo $path_key | sed 's/\.path/.url/')
        url=$(git config -f .gitmodules --get "$url_key")

        rm -rf $path; git submodule add $url $path; echo "$path has been initialized"

    done 3<tempfile

    rm tempfile
}

clone_themes
fix_git_repo
# clone_extra_themes
cd $current_dir
python parse.py
