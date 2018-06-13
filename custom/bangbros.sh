#!/bin/bash

if [[ "${releasesite,,}" =~ "monstersofcock" ]]; then
	SCENE_CATEGORY="43"
fi

#requires ImageMagick installed, uses "covert" command
function createGIFCover() {
	local sceneid=$(getValueFromSceneFile "id")
	writelog "Scene ID: ${sceneid}"
	if [[ "${sceneid}" != "" ]]; then
		
		local thumbs=""
		for x in {1..16}; do
			thumbs+="https://sm-members.bangbros.com/shoots/${releasesite,,}/${sceneid}/rollover/180/${x}.jpg "
		done
		writelog "Urls: ${thumbs}"
		local files=$(downloadImages "${thumbs}")
		writelog "Downloaded files: ${files}"
		local localgif="${outbasefile}_${sceneid}.gif"
		writelog "Making GIF: ${localgif}" 
		local cmd=$(convert -loop 0 -delay 80 ${files} "${localgif}")
		SCENE_COVER=$(uploadImages "-c" "${localgif}")
		writelog "Uploaded cover GIF: ${SCENE_COVER}"
	fi
}

function preMergeTemplate() {
	createGIFCover
}
