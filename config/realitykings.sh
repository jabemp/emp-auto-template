#MomsBangTeens -> moms-bang-teens
siteparturl=$(echo "$releasesite" | sed -e 's/\([[:lower:]]\)\([[:upper:]]\)/\1\n\2/g' -e 's/\([[:upper:]]\+\)\([[:upper:]][[:lower:]]\)/\1\n\2/g' -e 's/_\+/\n/g' | tr '\n' '-' | sed -r 's/\-$//g' | tr '[:upper:]' '[:lower:]')

if [[ "${siteparturl}" == "pure18" ]]; then
	siteparturl="pure-18"
fi
scenetries[0]="site = '$siteparturl' and date = '${releasedate}'"

function createGIFCover() {
	
	thumbs=$(getThumbUrls)
	writelog "Urls: ${thumbs}"
	local files=$(downloadImages "${thumbs}")
	writelog "Downloaded files: ${files}"
	local localgif="${outbasefile}_${sceneid}.gif"
	writelog "Making GIF: ${localgif}" 
	local cmd=$(convert -loop 0 -delay 80 ${files} "${localgif}")
	SCENE_COVER=$(uploadImages "-c" "${localgif}")
	writelog "Uploaded cover GIF: ${SCENE_COVER}"
}

function preMergeTemplate() {
	if [[ "${releasesite,,}" =~ (momslickteens|welivetogether) ]]; then
		SCENE_CATEGORY=23
	elif [[ "${releasesite,,}" == "bignaturals" ]]; then
		SCENE_CATEGORY=41
	fi
	createGIFCover
}
