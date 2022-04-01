#!/bin/sh

# This helper script will download TESS related data and bulk download
# files.
#
# Original author:
#   Pedram Ashofteh Ardakani <pedramardakani@pm.me>
# Contributing author(s):
# Copyright (C) 2022 Free Software Foundation, Inc.
#
# This is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option)
# any later version.
#
# This script is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this script. If not, see <http://www.gnu.org/licenses/>.

# Exit the script if any of the following commands fail
set -e

# Default arguments
latest=1
imagetype="ffir"
prefix="tesscurl_sector"
url="https://archive.stsci.edu/missions/tess/download_scripts/sector/"

help_print() {
    # Current script name
    me=$0

    # Print the output.
    cat <<EOF

Usage: $me [OPTION]...

Download data from TESS

Options:

 -t, --imagetype   STR    Image type, one of the following:
                          * "lc"       light curve
                          * "tp"       target pixel
                          * "dv"       data validation
                          * "fast-lc"  fast light curve
                          * "fast-tp"  fast target pixel
                          * "ffir"     full frame image raw
                          * "ffic"     full frame image calibrated
                          Current value: $imagetype

 -o, --output STR         Output file containing the links
                          Current value: $output

 --latest                 Download only the lastest image
                          Current value: $latest

 --all                    Download not just the latest, but all images
                          specified (opposite of --latest)

 --camera     INT         Download only data related to camera (1-4)

 --chip       INT         Download only data related to chip (1-4)
EOF
}

# Parse the arguments.
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        -s|--sector)
            sector="$2"
            if [ x"$sector" = x ]; then
                echo "No argument given to '--sector' ('-s')."
                exit 1;
            fi
            shift # past argument
            shift # past value
            ;;
        -t|--imagetype)
            imagetype="$2"
            if [ x"$imagetype" = x ]; then
                echo "No argument given to '--imagetype' ('-t')."
                exit 1;
            fi
            shift # past argument
            shift # past value
            ;;
        -o|--output)
            output="$2"
            if [ x"$output" = x ]; then
                echo "No argument given to '--output' ('-o')."
                exit 1;
            fi
            shift # past argument
            shift # past value
            ;;
        --camera)
            camera="$2"
            if [ x"$camera" = x ]; then
                echo "No argument given to '--camera'"
                exit 1;
            fi
            shift # past argument
            shift # past value
            ;;
        --chip)
            chip="$2"
            if [ x"$chip" = x ]; then
                echo "No argument given to '--chip'"
                exit 1;
            fi
            shift # past argument
            shift # past value
            ;;
        --latest)
            latest=1
            shift # past argument
            ;;
        --all)
            latest=0
            shift # past argument
            ;;
        -h|-P|--help|--printparams)
            help_print
            exit 0
            ;;
        *)
            echo "Unknown option '$1'. Aborting."
            exit 1
            ;;
    esac
done




# Check for mandatory variables
if [ x"$sector" = x ]; then
    echo "Please specify a valid sector number with option -s or --sector and try again"
    exit 1
fi

if [ x"$output" = x ]; then
    output="tess_links_sector_${sector}_${imagetype}.txt"
fi





# Download bulk file
filename="${prefix}_${sector}_${imagetype}.sh"
if [ ! -f "$1" ]; then
    echo "# Downloading sector ${sector} bulk file ..."
    wget $url -O $filename
fi




# Check if we want only the lastest items
if [ $latest -eq 1 ]; then
    latesttime=$(tail -1 $filename | awk '{split($6, a, "-"); print a[1];}')
    grep $latesttime $filename | awk '{print $NF}' | sort > $output
fi


exit 0
