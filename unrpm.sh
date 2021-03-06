#!/bin/bash

# 2019, Georg Sauthoff <mail@gms.tf>
# SPDX-License-Identifier: GPL-3.0-or-later

set -eu

verbose=0
list=0
filename=-
dir=$PWD

function usage
{
    cat <<EOF
$1 - unpack a RPM file

Usage: $1 [-C DIRECTORY] [-v|-t] [-|FILENAME.RPM]

Options:

  -C DIRECTORY    change in DIRECTORY before unpacking
  -t              list filenames instead of extracting
  -v              print filename while extracting them
EOF
}

function parse_args
{
    local a
    while getopts C:hvt a; do
        case "$a" in
            C)
                dir=$OPTARG
                ;;
            h)
                usage $0
                exit 0
                ;;
            v)
                verbose=1
                ;;
            t)
                list=1
                ;;
            *)
                usage $0
                exit 1
                ;;
        esac
    done
    if [ "$OPTIND" -gt $# ]; then
        usage $0
        exit 1
    fi
    shift $((OPTIND-1))
    filename=$(realpath "$1")
}

function main
{
    parse_args "$@"
    if [ "$dir" != "$PWD" ]; then
        cd "$dir"
    fi
    local flags=-di
    if [ "$list" = 1 ]; then
        flags=-t
    fi
    if [ "$verbose" = 1 ]; then
        flags+="v"
    fi
    rpm2cpio "$filename" | cpio --quiet $flags
}

main "$@"
