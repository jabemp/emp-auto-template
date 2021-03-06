
siteparturl=$(echo "$releasesite" | sed -e 's/\([[:lower:]]\)\([[:upper:]]\)/\1\n\2/g' -e 's/\([[:upper:]]\+\)\([[:upper:]][[:lower:]]\)/\1\n\2/g' -e 's/_\+/\n/g' | tr '\n' '-' | sed -r 's/\-$//g' | tr '[:upper:]' '[:lower:]')
scenetries[0]+=" and time='upcoming'"
scenetries+=("time = 'this-week' and date = '${releasedate}'")
scenetries+=("time = 'alltime' and date = '${releasedate}'")

SCENE_CATEGORY=23
function createGIFCover() {
	local sceneid=$(getValueFromSceneFile "id")
	writelog "Scene ID: ${sceneid}"
	if [[ "${sceneid}" != "" ]]; then
		
		local thumbs=""
		for x in {1..5}; do
			thumbs+="https://i2-hw.twistyscontent.com/scenes/${sceneid}/s300x225_${x}.jpg "
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
