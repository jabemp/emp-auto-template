#!/bin/bash

sitebaseurl="https://www.${network,,}.com/en"

scenetries=("${sitebaseurl}/videos/${releasesite,,}/AllCategories/0/Actor/0/upcoming/1")
scenetries+=("${sitebaseurl}/videos/${releasesite,,}/AllCategories/0/AllPornstars/0/updates/1")
scenetries+=("${sitebaseurl}/videos/AllCategories/0/Actor/0/upcoming/1")
scenetries+=("${sitebaseurl}/videos/AllCategories/0/Actor/0/updates/1")
scenetries+=("${sitebaseurl}/videos/${releasesite,,}")
scenetries+=("${sitebaseurl}/videos")
scenetries+=("${sitebaseurl}")

function getQueryOverrideParamsForSceneList() {
	local fetchurl="${1}"
	local dateparam="${2}"
	local remoteurl=$(downloadURL "${fetchurl}")
	echo "remoteurl = '${remoteurl}' and site = '${releasesite,,}' and date = '${dateparam}'"
}

function getQueryOverrideParamsForScene() {
	local fetchurl="${1}"
	local remoteurl=$(downloadURL "${fetchurl}")
	echo "url = '${remoteurl}'"
}

function preMergeTemplate {
	if [[ "${releasesite,,}" =~ "allgirl" ]]; then
			SCENE_CATEGORY="23"
	fi
}
