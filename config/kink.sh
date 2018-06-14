SCENE_CATEGORY=30
scenetries=("https://www.kink.com/channel/${releasesite,,}")
cookie="viewing-preferences=straight"

function getQueryOverrideParamsForSceneList() {
	local fetchurl="${1}"
	local dateparam="${2}"
	local remoteurl=$(downloadURL "${fetchurl}" "${cookie}")
	echo "remoteurl = '${remoteurl}' and date = '${dateparam}'"
}

function getQueryOverrideParamsForScene() {
	local fetchurl="${1}"
	local remoteurl=$(downloadURL "${fetchurl}" "${cookie}")
	echo "url = '${remoteurl}'"
}
