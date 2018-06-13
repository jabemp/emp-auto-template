#!/bin/bash

function writelog() {
	dt=$(date +"%Y-%m-%d %H:%M.%S")
	echo "${dt}: ${1}" >> "${logfile}"
}
function preMergeTemplate() {
	:
}
function postMergeTemplate() {
	if [[ "${uploadmode}" == "1" ]]; then
		addtemplateconfig="${outbasefile}_addtemplateconfig.txt"
		addTemplate
	elif [[ "${uploadmode}" == "2" ]]; then
		uploadconfig="${outbasefile}_uploadconfig.txt"
		upload
	fi
}
function getQueryOverrideParamsForSceneList() {
	echo ""
}
function getQueryOverrideParamsForScene() {
	echo ""
}

function getTorrentTitle() {
	
	local PICSET=""
	if [[ "${picsetincluded}" == "1" ]]; then
		PICSET=" + PicSet"
	fi
	
	if [[ "${SCENE_TITLE}" == "" ]]; then
		echo "[${SCENE_SITENAME_TITLE_CASE}] - ${SCENE_TITLE_CAST} (${SCENE_DATE}) [${SCENE_MEDIA_RESOLUTION_HEIGHT}]${PICSET}"
	else
		echo "[${SCENE_SITENAME_TITLE_CASE}] - ${SCENE_TITLE_CAST} - ${SCENE_TITLE} (${SCENE_DATE}) [${SCENE_MEDIA_RESOLUTION_HEIGHT}]${PICSET}"
	fi
}

function deleteWorkingFiles() {
	writelog "Looking for files that matches '${prefix}${releasesite,,}_*' in ${tempfolder}"
	#https://bugs.launchpad.net/ubuntu/+source/findutils/+bug/1347788
	$(cd ${tempfolder} && find ${tempfolder} -maxdepth 1 -name "${prefix}${releasesite,,}_*" -type f -exec rm '{}' \;)
	if [ -f "${screens}" ]; then
		$(cd ${tempfolder} && find "${screens}" -type f -exec rm '{}' \;)
	fi
}

function getPreloadedData() {
	local tempvarname="${1,,}"
	tempvarname="${tempvarname//-/_}"
	local dynvarname="${tempvarname//./_}"
	if [[ $dynvarname =~ ^[0-9] ]]; then
		dynvarname="_${dynvarname}"
	fi
	local dynvarvalue="${!dynvarname}"
	writelog "${dynvarname}=${dynvarvalue}"
	echo "${dynvarvalue}"
}
