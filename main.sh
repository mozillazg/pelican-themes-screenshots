#!/usr/bin/env bash

current_dir=$PWD

extra_repos='https://github.com/duilio/pelican-octopress-theme/'

function clone_themes() {
    rm -rf $current_dir/public/data/*/
    cd $current_dir/public/data
    git clone git://github.com/getpelican/pelican-themes --depth=1
    git submodule sync
    git submodule init
    git submodule update
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
        # read -p "Are you sure you want to delete $path and re-initialize as a new submodule? " yn
        # case $yn in
        #     [Yy]* ) rm -rf $path; git submodule add $url $path; echo "$path has been initialized";;
        #     [Nn]* ) exit;;
        #     * ) echo "Please answer yes or no.";;
        # esac

    done 3<tempfile

    rm tempfile
}

# clone_themes
# fix_git_repo
# clone_extra_themes
python parse.py
