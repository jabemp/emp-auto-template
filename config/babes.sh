siteparturl=$(echo "$releasesite" | sed -e 's/\([[:lower:]]\)\([[:upper:]]\)/\1\n\2/g' -e 's/\([[:upper:]]\+\)\([[:upper:]][[:lower:]]\)/\1\n\2/g' -e 's/_\+/\n/g' | tr '\n' '-' | sed -r 's/\-$//g' | tr '[:upper:]' '[:lower:]')

scenetries=("site = '${siteparturl}' and time ='upcoming' and date = '${releasedate}'")
scenetries+=("site = '${siteparturl}' and time = 'alltime' and date = '${releasedate}'")

function createGIFCover() {
	local sceneid=$(getValueFromSceneFile "id")
	writelog "Scene ID: ${sceneid}"
	if [[ "${sceneid}" != "" ]]; then
		
		local thumbs=""
		for x in {1..6}; do
			thumbs+="https://static-hw.babescontent.com/scenes/${sceneid}/s310x161_${x}.jpg "
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
