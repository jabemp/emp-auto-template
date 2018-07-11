#!/bin/bash

function getValueFromXmlFile() {
	local val=$(xmllint --xpath "string(//${1})" "${2}")
	echo "$val"
}

function getValueFromSceneFile() {
	local val=$(getValueFromXmlFile "${1}" "${scenedatafile}")
	echo "${val}"
}

function getTitle() {
	local val=$(getValueFromSceneFile "title")
	echo "${val}"
}

function getCast() {
	local val=$(getValueFromSceneFile "cast")
	echo "${val}"
}

function getTitleCast() {
	local temptitle=$(getTitle)
	local val=""
	#if scene has an official title, remove it from the releasename (and assume we are left with the female cast)
	if [[ "${temptitle}" != "" ]]; then
		temptitle=$(echo "${temptitle}" | sed -r 's/(\.|:|!|,)//g' | sed -r 's/\&/And/g' | sed -r 's/ - / /g' | sed -r "s/'//g")
		val=$(echo "${releasecasttitle}" | sed -r "s/${temptitle}//gi" | sed -r 's/ and / \& /gi' | sed -r 's/\s+$//g')
	else
		#assume the data in the release name is just female cast
		val="${releasecasttitle}"
	fi
	echo "${val}"
}

function getDate() {
	local val=$(getValueFromSceneFile "dateiso")
	if [[ "${val}" == "" ]]; then
		val=$(echo "${releasedate}" | awk -F. '{printf "20%s-%s-%s",$1,$2,$3}')
	fi
	echo "${val}"
}

function getDescription() {
	local val=$(getValueFromSceneFile "desc")
	echo "${val}"
}

function getTagsRaw() {
	local val=$(getValueFromSceneFile "tags")
	val=$(echo "$val" | tr '\n' ' ')
	echo "${val}"
}

function getCoverPic() {
	local val=$(getValueFromSceneFile "poster")
	echo "${val}"
}

function getPicUrls() {
	local val=$(getValueFromSceneFile "images" | sed -r 's/http/ http/g')
	echo "${val}"
}

function getThumbUrls() {
	local val=$(getValueFromSceneFile "thumbs" | sed -r 's/http/ http/g')
	echo "${val}"
}

function getPhotoUrls() {
	local val=$(getValueFromSceneFile "photos" | sed -r 's/http/ http/g')
	echo "${val}"
}
