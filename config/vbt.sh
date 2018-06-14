dlimages="1"
fakenetwork="1"
scenepicsoption="-m"

function preMergeTemplate() {
	if [[ "${releasesite,,}" == "blacked" ]]; then
		SCENE_CATEGORY=43
	elif [[ "${releasesite,,}" == "tushy" ]]; then
		SCENE_CATEGORY=2
	fi
}

function getTorrentTitle() {

	if [[ "${SCENE_TITLE}" == "" ]]; then
		echo "[${SCENE_SITENAME_TITLE_CASE^^}] - ${SCENE_TITLE_CAST} (${SCENE_DATE}) [${SCENE_MEDIA_RESOLUTION_HEIGHT}]"
	else
		echo "[${SCENE_SITENAME_TITLE_CASE^^}] - ${SCENE_TITLE_CAST} - ${SCENE_TITLE} (${SCENE_DATE}) [${SCENE_MEDIA_RESOLUTION_HEIGHT}]"
	fi
}
