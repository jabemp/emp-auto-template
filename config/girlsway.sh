#!/bin/bash

SCENE_CATEGORY=23
sitebaseurl="https://www.${network,,}.com/en"
siteparturl="${releasesite}"

if [[ "${releasesite}" == "GirlsWay" ]]; then
	siteparturl="${releasesite,,}"
elif [[ "${releasesite}" == "SexTapeLesbians" ]]; then
	siteparturl="SextapeLesbians"
fi

scenetries=("${sitebaseurl}/videos/${siteparturl}/upcoming/0/Pornstar/1/0")
scenetries+=("${sitebaseurl}/videos/${siteparturl}/updates/0/Pornstar/1/")
scenetries+=("${sitebaseurl}/videos/${siteparturl}")
scenetries+=("${sitebaseurl}/videos")
scenetries+=("${sitebaseurl}/")

function getQueryOverrideParamsForSceneList() {
	local fetchurl="${1}"
	local dateparam="${2}"
	local remoteurl=$(downloadURL "${fetchurl}")
	echo "remoteurl = '${remoteurl}' and site = '${siteparturl}' and date = '${dateparam}'"
}

function getQueryOverrideParamsForScene() {
	local fetchurl="${1}"
	local remoteurl=$(downloadURL "${fetchurl}")
	echo "url = '${remoteurl}'"
}

function getTorrentTitle() {
	local PICSET=""
	if [[ "${picsetincluded}" == "1" ]]; then
		PICSET=" + PicSet"
	fi
	echo "[${SCENE_SITENAME}] - ${SCENE_CAST} - ${SCENE_TITLE} (${SCENE_DATE}) [${SCENE_MEDIA_RESOLUTION_HEIGHT}]${PICSET}"
}
