#!/bin/bash

#Optional site specific tagfix with sed replace expressions
tagfixsite="${configfolder}/tagfix_${releasesite,,}.txt"

#Optional network specific tagfix with sed replace expressions
tagfixnetwork="${configfolder}/tagfix_${network,,}.txt"

function getNumericPart() {
	local val=$(echo "$1" | sed -r 's/[^0-9\.]+//g')
	echo "$val" 
}

function getRoundNumber() {
	local val=$(printf '%.*f\n' 0 "$1")
	echo "$val"
}

function getFrameRateTag() {
	local numpart=$(getNumericPart "$1")
	local roundfps=$(getRoundNumber "$numpart")
	local fpstag=""
	for i in "${fpsList[@]}"
	do
		if [[ "$i" == "$roundfps" ]]; then
			fpstag="${roundfps}.fps"
			break
		fi
	done
	echo "${fpstag}"
}


function getTagsFromFile() {
	local val=$(getValueFromKeyInFile "$1" "$2")
	echo "$val"
}

function getSiteTags() {
	local val=$(getTagsFromFile "${tagssitesfile}" "$1" | sed -r 's/\s+/,/g')
	echo "$val"
}

function getAugmentedTagsForSite() {
	tagsitefile="${configfolder}/tags_${1,,}.txt"
	local tags=""
	if [ -f "${tagsitefile}" ]; then
		IFS=',' read -ra sitetags <<< "$2"
		for sitetag in "${sitetags[@]}"; do
			addedtag=$(getTagsFromFile "${tagsitefile}" "$sitetag" | sed -r 's/\s+/,/gi')
			if [[ "$addedtag" != "" ]]; then
				tags+=",$addedtag"
			fi
		done
		unset IFS
	fi
	echo "$tags"
}

function getActorTags() {	
	local actortags=""

	IFS=',' read -ra ACTORS <<< "$1"
	for actor in "${ACTORS[@]}"; do
		actor=$(echo "$actor" | sed -r 's/ /./g' | tr '[:upper:]' '[:lower:]')
		val=$(getTagsFromFile "${tagsactorsfile}" "$actor" | sed -r 's/\s+/,/gi')
		if [[ "$val" != "" ]]; then
			actortags+=",$val "
		fi
	done
	unset IFS
	echo "$actortags"
}

function getTags() {
	local tagsinput=$(getTagsRaw | sed -r 's/, /,/g')
	local castastags=$(getCast | sed -r 's/, /,/g;s/ \& /,/g')
	local casttags=$(getActorTags "$castastags")
	local sitetags=$(getSiteTags "$releasesite")
	local resHeight=$(getMediaResHeight)
	local networktag=""
	if [[ "$network" != "" ]] && [[ "$fakenetwork" != "1" ]]; then
		networktag="${network}.com"
	fi
	
	if [[ "${addExtensionAsTag}" == "1" ]]; then
		extensionTag="${mediaextension}"
	fi
	
	if [[ "${addDateAsTag}" == "1" ]]; then
		#assumes ISO format!
		if [[ "${dateTagMode}" == "1" ]]; then
			dateTag="${SCENE_DATE//-/.}"
		elif [[ "${dateTagMode}" == "2" ]]; then
			dateTag=$(date -d"${SCENE_DATE}" +"%Y.%B")
		fi
		
	fi
	
	if [[ "${addFpsAsTag}" == "1" ]]; then
		fpsTag=$(getFrameRateTag "${SCENE_MEDIA_FRAMERATE}")
	fi
	
	tagsinput+=",${castastags},${casttags},${sitetags},${releasesite}.com,${networktag},${resHeight},${extensionTag},${dateTag},${fpsTag}"
	local tagsfixed=""
	IFS=',' read -ra TAGARRAY <<< "$tagsinput"
	for tag in "${TAGARRAY[@]}"; do
		if [[ "$tag" == "" ]]; then
			continue
		fi
		#echo "Current tag: [$tag]"
		#clean junk, lower case &  trim each tag
		tag=$(echo "$tag" | sed -r "s/(\-|\/)/./gi;s/('n|\&)/and/g;s/[^a-z0-9\. ]//gi" | sed -r 's/\s+$//g' | sed -r 's/^\s+//g' | sed -r 's/\s+/ /g' | tr '[:upper:]' '[:lower:]')
		#echo "Current tag, pre-cleaned: [$tag]"
		tag=$(echo "$tag" | sed -r -f "${tagfixfile}" | sed -r 's/\s+$//g' | sed -r 's/^\s+//g')
		
		#echo "Current tag, custom-cleaned: [$tag]"
		if [[ "$tag" == "" ]]; then
			continue
		fi
		if [ -f "${tagfixnetwork}" ]; then
			tag=$(echo "$tag" | sed -r -f "${tagfixnetwork}" | sed -r 's/\s+$//g' | sed -r 's/^\s+//g')
		fi
		if [[ "$tag" == "" ]]; then
			continue
		fi
		if [ -f "${tagfixsite}" ] && [[ "$tagfixnetwork" != "${tagfixsite}" ]]; then
			#echo "site fix"
			tag=$(echo "$tag" | sed -r -f "${tagfixsite}" | sed -r 's/\s+$//g' | sed -r 's/^\s+//g')
		fi
		if [[ "$tag" == "" ]]; then
			continue
		fi
		tagsfixed+=",$tag"
	done
	unset IFS
	tagsfixed=$(echo "$tagsfixed" | sed -r 's/,+/,/g' | sed -r 's/(^,|,$)//g' | tr ' ' '.' | sed -r 's/\.+/./g' | tr ',' '\n' | sort | uniq | tr '\n' ' ' | tr '[:upper:]' '[:lower:]')
	
	echo "$tagsfixed"
}
