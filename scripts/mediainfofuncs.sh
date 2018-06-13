#!/bin/bash

function createMediaInfoReport() {
	local mediainfooutput="${outbasefile}_mediainfo.xml"
	#writelog "Creating media info report..."
	mediainfo --output=XML "$1" > "$mediainfooutput"
	echo "$mediainfooutput"
}

function getMediaInfoProperty() {
	local val=$(xmllint --xpath "string(${1})" "$mediainforeport")
	echo "$val"
}
function getMediaFormat() {
	local val=$(getMediaInfoProperty "/Mediainfo/File/track[@type='General']/Format")
	echo "$val"
}
function getMediaFileSize() {
	local val=$(getMediaInfoProperty "/Mediainfo/File/track[@type='General']/File_size")
	echo "$val"
}
function getMediaBitRate() {
	local val=$(getMediaInfoProperty "/Mediainfo/File/track[@type='General']/Overall_bit_rate")
	echo "$val"
}
function getMediaDuration() {
	local val=$(getMediaInfoProperty "/Mediainfo/File/track[@type='General']/Duration")
	echo "$val"
}
function getMediaResolution() {
	local width=$(getMediaInfoProperty "/Mediainfo/File/track[@type='Video']/Width")
	local height=$(getMediaInfoProperty "/Mediainfo/File/track[@type='Video']/Height")
	local res=$(echo "${width}x ${height}" | sed -r 's/pixels//g')
	echo "$res"
}
function getMediaResHeight() {
	local height=$(getMediaInfoProperty "/Mediainfo/File/track[@type='Video']/Height")
	local res=$(echo "${height}" | sed -r 's/pixels//g' | sed -r 's/ //g')
	echo "${res}p"
}
function getMediaFramerate() {
	local fp=$(getMediaInfoProperty "/Mediainfo/File/track[@type='Video']/Frame_rate")
	fp=$(echo "$fp" | sed -r 's/ \(.+\)//g')
	echo "$fp"
}

function setMediaInfoVars() {
	SCENE_MEDIA_FORMAT=$(getMediaFormat)
	SCENE_MEDIA_FILESIZE=$(getMediaFileSize)
	SCENE_MEDIA_BITRATE=$(getMediaBitRate)
	SCENE_MEDIA_DURATION=$(getMediaDuration)
	SCENE_MEDIA_RESOLUTION=$(getMediaResolution)
	SCENE_MEDIA_RESOLUTION_HEIGHT=$(getMediaResHeight)
	SCENE_MEDIA_FRAMERATE=$(getMediaFramerate)
}
