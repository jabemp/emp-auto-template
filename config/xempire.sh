#!/bin/bash

scenetries[0]+=" and time='upcoming'"
scenetries+=("site = '${releasesite}' and time = 'current' and date = '${releasedate}'")
scenetries+=("site = 'xempire' and time = 'current' and date = '${releasedate}'")
scenetries+=("site = 'all' and time = 'current' and date = '${releasedate}'")


function preMergeTemplate {
	if [[ "${SCENE_TAGS,,}" =~ "anal" ]]; then
		SCENE_CATEGORY="2"
	elif [[ "${releasesite,,}" == "lesbianx" ]]; then
		SCENE_CATEGORY="23"
	elif [[ "${releasesite,,}" == "darkx" ]]; then
		SCENE_CATEGORY="43"
	fi
}
