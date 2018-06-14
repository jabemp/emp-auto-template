SCENE_CATEGORY="2"
dlimages="1"
scenepicsoption="-m"

function getQueryOverrideParamsForScene() {
	local fetchurl="${1}"
	requestSettings=", \"requestSettings\": {\"cookies\": [{ \"domain\": \"www.pervcity.com\", \"name\": \"iagreed\", \"value\": \"accepted\" } ] }"
	local remoteurl=$(downloadURLPhantomJS "${fetchurl}" "${requestSettings}")
	echo "url = '${remoteurl}'"
}
