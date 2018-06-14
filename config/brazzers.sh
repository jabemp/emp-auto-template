siteparturl=$(echo "$releasesite" | sed -e 's/\([[:lower:]]\)\([[:upper:]]\)/\1\n\2/g' -e 's/\([[:upper:]]\+\)\([[:upper:]][[:lower:]]\)/\1\n\2/g' -e 's/_\+/\n/g' | tr '\n' '-' | sed -r 's/\-$//g' | tr '[:upper:]' '[:lower:]')

baseurl="https://www.${network,,}.com"
mainurl="$baseurl/videos/$siteparturl/all-pornstars/all-categories"

scenetries=("${mainurl}/upcoming/bydate/")
scenetries+=("${mainurl}/thisweek/bydate/")
scenetries+=("${mainurl}/alltime/bydate/")

function getQueryOverrideParamsForSceneList() {
	local fetchurl="${1}"
	local dateparam="${2}"
	local remoteurl=$(downloadURLPhantomJS "${fetchurl}")
	echo "remoteurl = '${remoteurl}' and date = '${dateparam}'"
}

function createGIFCover() {
	local sceneid=$(getValueFromSceneFile "id")
	writelog "Scene ID: ${sceneid}"
	if [[ "${sceneid}" != "" ]]; then
		
		local thumbs=""
		for x in {1..5}; do
			thumbs+="https://static-vz.brazzerscontent.com/scenes/${sceneid}/br${x}.jpg "
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
	if [[ "${releasesite,,}" =~ "bigtits" || "${releasesite,,}" =~ "boobs" ]]; then
		SCENE_CATEGORY="8"
	elif [[ "${releasesite,,}" =~ "butts" ]]; then
		SCENE_CATEGORY="2"
	elif [[ "${releasesite,,}" =~ "hotandmean" ]]; then
		SCENE_CATEGORY="23"
	fi
	createGIFCover
}
