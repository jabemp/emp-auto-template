siteparturl=$(echo "$releasesite" | sed -e 's/\([[:lower:]]\)\([[:upper:]]\)/\1\n\2/g' -e 's/\([[:upper:]]\+\)\([[:upper:]][[:lower:]]\)/\1\n\2/g' -e 's/_\+/\n/g' | tr '\n' '-' | sed -r 's/\-$//g' | tr '[:upper:]' '[:lower:]')

scenetries[0]="site = '$siteparturl' and date = '${releasedate}'"

function getTorrentTitle() {
	echo "[${SCENE_SITENAME}] - ${SCENE_CAST} - ${SCENE_TITLE} (${SCENE_DATE}) [${SCENE_MEDIA_RESOLUTION_HEIGHT}]"
}

function createGIFCover() {
	local sceneid=$(getValueFromSceneFile "id")
	writelog "Scene ID: ${sceneid}"
	if [[ "${sceneid}" != "" ]]; then
		
		local thumbs=""
		for x in {1..5}; do
			thumbs+="http://static-ht.mofoscontent.com/scenes/${sceneid}/313x209_${x}.jpg "
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
	if [[ "${releasesite,,}" =~ "latin" ]]; then
		SCENE_CATEGORY="16"
	elif [[ "${releasesite,,}" =~ "girlsgonepink" ]]; then
		SCENE_CATEGORY="23"
	elif [[ "${releasesite,,}" =~ "ebony" ]]; then
		SCENE_CATEGORY="7"
	elif [[ "${releasesite,,}" =~ "anal" ]]; then
		SCENE_CATEGORY="2"
	fi
	createGIFCover
}
