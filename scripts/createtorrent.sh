#!/bin/bash

function createTorrent() {
	local inputfile="$1"
	local outputfolder="$2"
	local announceurl="$3"
	if [ ! -e "$inputfile" ] || [ ! -d "$outputfolder" ]; then
		echo "invalid input file and/or output folder"
		return 1
	fi
	if [[ ! "$announceurl" =~ ^http.* ]]; then
		echo "invalid announce url, must start with http"
    	return 1
	fi
	local filename=$(basename "$1")
	
	if [ -f "$inputfile" ]; then
		filenamebase="${filename%.*}"
	else
		filenamebase="${filename}"
	fi
	
	torrentfullpath="${outputfolder}/${filenamebase}.torrent"
	local params="-P -c \"\" -f -o ${torrentfullpath} ${inputfile} ${announceurl}"
	local cmd="python3 ${torrentcreateclient} $params"
	#echo "PY3CT command: $cmd"
	local cmdrun=$(eval $cmd)
	echo "$torrentfullpath"
}
