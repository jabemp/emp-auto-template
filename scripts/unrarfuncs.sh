#!/bin/bash

function getRarFile() {
	local rarfile=$(find "${1}" -maxdepth 1 -type f -name '*.rar' | head -n 1)
	echo "${rarfile}"
}

function getMp4File() {
	local mp4file=$(find "${1}" -maxdepth 1 -type f -name '*.mp4' | head -n 1)
	echo "${mp4file}"
}

function getVolumeFile() {
	local filenameinside=$(unrar lb "${1}")
	echo "${filenameinside}"
}

function extractRarFile() {
	local souredir="${1}"
	local targetdir="${2}"
	#if no targetdir give, assume same directory
	if [[ "${targetdir}" == "" ]]; then
		targetdir="${1}"
	fi
	#does source dir actually exist?
	if [ ! -d "${souredir}" ]; then
		writelog "Source directory ${souredir} does not exist"
		return 1
	fi
	#does target dir actually exist?
	if [ ! -d "${targetdir}" ]; then
		writelog "Taget directory ${targetdir} does not exist"
		return 1
	fi
	local rarfile=$(getRarFile "${souredir}")
	local fullpath=""
	
	#do we have a existing rar file?
	if [ -f "${rarfile}" ]; then
		local targetfile=$(getVolumeFile "${rarfile}")
		fullpath="${targetdir}/${targetfile}"
		
		#only extract if file in rar file not already exists
		if [ ! -f "${targetdir}/${targetfile}" ]; then
			$(unrar x -inul -y "${rarfile}" "${targetdir}")
		fi
	else
		writelog "No rar files found in '${souredir}'"
		mp4file=$(getMp4File "${souredir}")
		if [ -f "${mp4file}" ]; then
			fullpath="${targetdir}/${mp4file}"
		fi
		
	fi
	echo "${fullpath}"
}

function getFileExtension() {
	local filenameOnly=$(basename "$1")
	local extension="${filenameOnly##*.}"
	echo "${extension}"
}
