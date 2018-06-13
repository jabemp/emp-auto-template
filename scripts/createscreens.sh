#!/bin/bash

maxsize=3100000

function createScreens() {
	if [ ! -f "$1" ]; then
		echo "invalid input: $1"
		return 1
	fi
	curdir=$(dirname "$1")
	filename=$(basename "$1")
	filenamebase="${filename%.*}"
	local outopts=""
	local jpgscreen=""
	#if arg 2 is supplied, assume it's a custom output directory
	if [[ "$2" != "" && -d "$2" ]]; then
		outopts=" -O $2"
		jpgscreen="${2}/${filenamebase}.jpg"
	else
		jpgscreen="${curdir}/${filenamebase}.jpg"
	fi
	local cmd="$mtnfolder/mtn -f $mtnfolder/tahomabd.ttf -c 3 -w 1280 -o .jpg -s 30 $outopts $1"
	local runcmd=$(eval $cmd)
	
	#if filesize exceeds certain limit, re run with fewer screens...and hope for the best :P
	actualsize=$(stat -c %s "$jpgscreen")
	if [ -f "$jpgscreen" ] && [ $actualsize -gt $maxsize ]; then
		rm "$jpgscreen"
		local cmd="$mtnfolder/mtn -f $mtnfolder/tahomabd.ttf -c 3 -w 1280 -o .jpg -s 45 $outopts $1"
		local runcmd=$(eval $cmd)
	fi
	
	actualsize=$(stat -c %s "$jpgscreen")
	if [ -f "$jpgscreen" ] && [ $actualsize -gt $maxsize ]; then
		rm "$jpgscreen"
		local cmd="$mtnfolder/mtn -f $mtnfolder/tahomabd.ttf -c 3 -w 1280 -o .jpg -s 60 $outopts $1"
		local runcmd=$(eval $cmd)
	fi
	
	echo "$jpgscreen"
}
