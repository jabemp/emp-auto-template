#!/bin/bash

#folder with all scripts related to this tool
scriptsfolder="${BASH_SOURCE%/*}"
if [[ ! -d "${scriptsfolder}" ]]; then scriptsfolder="$PWD"; fi

. "${scriptsfolder}/../config/settings.cfg"

if [ ! -d "${tempfolder}" ]; then
    echo "Temporary folder does not exist, check variable 'tempfolder'"
    exit 1
fi

if [ ! -d "${downloadfolder}" ]; then
    echo "Download folder does not exist, check variable 'downloadfolder'"
    exit 1
fi

if [ ! -d "${torrentfilefolder}" ]; then
    echo "Torrent file folder does not exist, check variable 'torrentfilefolder'"
    exit 1
fi

if [ ! -f "${trackercookiefile}" ]; then
    echo "Missing EMP cookie file, check variable 'trackercookiefile'"
    exit 1
fi

if [[ "${announceurl}" == "CHANGEME" ]] || [[ "${announceurl}" == "" ]]; then
    echo "Your personal EMP announce url is not configured, check variable 'announceurl'"
    exit 1
fi

#import functions
. "${scriptsfolder}/corefuncs.sh"
. "${scriptsfolder}/mediainfofuncs.sh"
. "${scriptsfolder}/unrarfuncs.sh"
. "${scriptsfolder}/keyval.sh"
. "${scriptsfolder}/yql.sh"

#is picset included? will be reflected in torrent title. Should be overridden in custom config
picsetincluded="0"

if [ "$#" -lt 1 ]; then
    echo "Missing parameters, must supply <input directory path>"
    exit 1
fi

inputdir="${1}"
url="${2}"

if [ ! -d "${inputdir}" ]; then
	echo "Directory '${inputdir}' does not exist"
	exit 1
fi

releasename=$(basename "${inputdir}")
#yy.mm.dd
regex="(.*?)\.([0-9]{2}\.[0-9]{2}\.[0-9]{2}|E[0-9]{2,4})\.(.*)\.XXX.*"
releasesite=$(echo "${releasename}" | sed -r "s/${regex}/\1/")
releasedate=$(echo "${releasename}" | sed -r "s/${regex}/\2/")
releasecasttitle=$(echo "${releasename}" | sed -r "s/${regex}/\3/" | tr '.' ' ')

if [ "${releasename}" == "" ] || [ "${releasesite}" == "" ] || [ "${releasedate}" == "" ]; then
	echo "Unrecognized release format, should match: ${regex}"
	exit 1
fi

echo "Processing ${releasename}"
echo "name : ${releasename}"
echo "site : ${releasesite}"
echo "date : ${releasedate}"
echo "cast/title: ${releasecasttitle}"

network=$(getKeyFromValueInFile "${networks}" "${releasesite}")
echo "network: ${network}"

prefix=""
if [[ "${network}" != "" ]]; then
	prefix="${network,,}_"
fi

if [ "${network}" == "" ] && ! grep -Fxqi "${releasesite}" "${sites}"  
then 
   echo "site ${releasesite} not found in ${networks} or in ${sites}, quitting"
   exit 1
fi

outbasefile="${tempfolder}/${prefix}${releasesite,,}"
logfile="${outbasefile}.log"
if [ -f "${logfile}" ]; then
	rm "${logfile}"
fi
writelog "Processing ${releasename}"
. "${scriptsfolder}/templating.sh"

if [ ! -f "${presentationtemplate}" ]; then
	writelog "Template does not exist, quitting"
	exit 1
fi
writelog "Presentation template: ${presentationtemplate}"
echo "Presentation template: ${presentationtemplate}"

indextablename=""
scenetablename=""
scenetry=""
if [[ "$network" != "" ]]; then
	scenetry="site = '${releasesite}' and"
	indextablename="${network,,}.xml"
	scenetablename="${network,,}_scene.xml"
else
	indextablename="${releasesite,,}.xml"
	scenetablename="${releasesite,,}_scene.xml"
fi

scenetry+=" date = '$releasedate'"
scenetries=("$scenetry")

. "${scriptsfolder}/customconfig.sh"

if [ -f "${preloadedvariables}" ]; then
	. "${preloadedvariables}"
fi

preloadedurl=$(getPreloadedData "${releasesite}_${releasedate}_url")
if [[ "${url}" == "" ]] && [[ "${preloadedurl}" != "" ]]; then
	url="${preloadedurl}"
fi

sc=0
if [[ "${url}" == "" ]]; then
	for i in "${scenetries[@]}"
	do
		((sc++))
		echo "Attempt: $sc of ${#scenetries[@]}"
		overrideparams=$(getQueryOverrideParamsForSceneList "${i}" "${releasedate}")
		if [[ "${overrideparams}" != "" ]]; then
			query=$(prepareYqlQuery "${indextablename}" "${overrideparams}")
		else
			query=$(prepareYqlQuery "${indextablename}" "${i}")
		fi
		
		scenelistfile=$(runYqlQuery "$query" "scenelist")
		url=$(getUrlFromSceneList "$scenelistfile" "$releasesite" "$releasecasttitle")
		if [[ "${url}" != "" ]]; then
			break
		elif [[ $sc -gt 1 ]]; then
			echo "Sleeing for 3 sec..."
			sleep 3s
		fi
			
	done

	if [[ "${url}" == "" ]]; then
		writelog "Unable to find scene url, exiting"
		echo "Unable to find scene url, exiting"
		exit 1
	fi
else
	writelog "Scene url supplied by argument or is preloaded from config"
	echo "Scene url supplied by argument or is preloaded from config"
fi


writelog "Scene url: ${url}"
echo "Scene url: ${url}"

overrideparams=$(getQueryOverrideParamsForScene "${url}")
if [[ "${overrideparams}" != "" ]]; then
	query=$(prepareYqlQuery "${scenetablename}" "${overrideparams}")
else
	query=$(prepareYqlQuery "${scenetablename}" "url = '${url}'")
fi

scenedatafile=$(runYqlQuery "$query" "scenedata")

if [ ! -f "${scenedatafile}" ]; then
	writelog "Scene data file missing, exiting"
	exit 1
fi
writelog "Scene data file: ${scenedatafile}"
echo "Scene data file: ${scenedatafile}"

scenecount=$(xmllint --xpath "count(//scene)" "${scenedatafile}")
if [[ "${scenecount}" != "1" ]]; then
	writelog "Error in '${scenedatafile}', scene tag missing"
	exit 1
fi

. "${scriptsfolder}/scenefuncs.sh"

#TODO: ensure we have key fields with data in scene data xml.

preloadedmediafile=$(getPreloadedData "${releasesite}_${releasedate}_mediafile")
if [[ "${preloadedmediafile}" != "" ]]; then
	mediafile="${preloadedmediafile}"
else
	writelog "Extracting media file..."
	echo "Extracting media file..."
	mediafile=$(extractRarFile "${inputdir}" "${downloadfolder}")
fi

if [ ! -f "${mediafile}" ]; then
		writelog "Extraction failed, exiting"
	exit 1
fi
writelog "Media file: ${mediafile}"
echo "Media file: ${mediafile}"

mediaextension=$(getFileExtension "${mediafile}")

mediainforeport=$(createMediaInfoReport "${mediafile}")
if [ ! -f "${mediainforeport}" ]; then
	writelog "Creating mediainfo report failed, exiting"
	exit 1
fi
writelog "Media info report: ${mediainforeport}"
echo "Media info report: ${mediainforeport}"

setMediaInfoVars

. "${screensscript}"

preloadedscreens=$(getPreloadedData "${releasesite}_${releasedate}_screens")
if [[ "${preloadedscreens}" == "" ]]; then
	writelog "Creating screens and saving to ${tempfolder}"
	echo "Creating screens and saving to ${tempfolder}"

	screens=$(createScreens "${mediafile}" "${tempfolder}")
	if [ ! -f "${screens}" ]; then
		writelog "Creating screens failed, exiting"
		exit 1
	fi
	writelog "Screens: ${screens}"
	echo "Screens: ${screens}"
else
	writelog "Pre-generated screens has been loaded from config, skipping creating."
	echo "Pre-generated screens has been loaded from config, skipping creating."
fi
. "${torrentcreatescript}"
. "${trackerconfig}"

SCENE_SITENAME="${releasesite}"
SCENE_SITENAME_TITLE_CASE=$(echo "$releasesite" | sed -e 's/\([[:lower:]]\)\([[:upper:]]\)/\1\n\2/g' -e 's/\([[:upper:]]\+\)\([[:upper:]][[:lower:]]\)/\1\n\2/g' -e 's/_\+/\n/g' | tr '\n' ' ' | sed -r 's/ $//g')

SCENE_TITLE=$(getTitle)
writelog "Scene title: $SCENE_TITLE"
echo "Scene title: $SCENE_TITLE"

SCENE_DATE=$(getDate)
writelog "Scene date: $SCENE_DATE"
echo "Scene date: $SCENE_DATE"

SCENE_CAST=$(getCast)
writelog "Scene cast: $SCENE_CAST"
echo "Scene cast: $SCENE_CAST"

SCENE_TITLE_CAST=$(getTitleCast)
writelog "Scene title cast: $SCENE_TITLE_CAST"
echo "Scene title cast: $SCENE_TITLE_CAST"

scenecover=$(getCoverPic)
writelog "Scene cover: $scenecover"
echo "Scene cover: $scenecover"

SCENE_DESCRIPTION=$(getDescription)
writelog "Scene description: $SCENE_DESCRIPTION"
echo "Scene description: $SCENE_DESCRIPTION"
echo

SCENE_CUSTOM_DESCRIPTION=$(getPreloadedData "${releasesite}_${releasedate}_desc")
writelog "Scene custom description: $SCENE_CUSTOM_DESCRIPTION"
echo "Scene custom description: $SCENE_CUSTOM_DESCRIPTION"
echo

SCENE_TAGS_RAW=$(getTagsRaw)
writelog "Scene tags raw: $SCENE_TAGS_RAW"
echo "Scene tags raw: $SCENE_TAGS_RAW"
echo

. "${scriptsfolder}/tags.sh"

SCENE_TAGS=$(getTags)
writelog "Scene tags: ${SCENE_TAGS}"
echo "Scene tags: ${SCENE_TAGS}"

preloadedtags=$(getPreloadedData "${releasesite}_${releasedate}_tags")
if [[ "${preloadedtags}" != "" ]]; then
	SCENE_TAGS="${SCENE_TAGS} ${preloadedtags}"
fi

preloadedmainimage=$(getPreloadedData "${releasesite}_${releasedate}_mainimage")
if [[ "${preloadedmainimage}" != "" ]]; then
	SCENE_MAINIMAGE="${preloadedmainimage}"
fi

preloadedcover=$(getPreloadedData "${releasesite}_${releasedate}_cover")
if [[ "${preloadedcover}" != "" ]]; then
	SCENE_COVER="${preloadedcover}"
else
	#some sites requires images to be downloaded first before uploaded to jerking
	if [[ "${dlimages}" == "1" ]] && [[ "${scenecover}" != "" ]]; then
		writelog "Pre-downloading scene cover"
		echo "Pre-downloading scene cover"
		scenecover=$(downloadImages "${scenecover}")
		if [[ "$scenecover" == "" ]]; then
			writelog "Pre-downloading cover failed, exiting"
			echo "Pre-downloading cover failed, exiting"
			exit 1
		fi
	fi
	writelog "Uploading scene cover"
	echo "Uploading scene cover"
	SCENE_COVER=$(uploadImages "-c" "$scenecover")
fi

if [[ "${SCENE_MAINIMAGE}" == "" ]] && [[ "${SCENE_COVER}" != "" ]]; then
	SCENE_MAINIMAGE="${SCENE_COVER}"
fi


if [[ "${SCENE_COVER}" == "" ]]; then
	writelog "Uploading scene cover failed, exiting"
	echo "Uploading scene cover failed, exiting"
	exit 1
fi
writelog "Scene cover uploaded: $SCENE_COVER"
echo "Scene cover uploaded: $SCENE_COVER"

preloadedimages=$(getPreloadedData "${releasesite}_${releasedate}_images")
if [[ "${preloadedimages}" != "" ]]; then
	SCENE_IMAGES="${preloadedimages}"
else
	scenepics=$(getPicUrls)
	writelog "Scene pics: $scenepics"

	#some sites requires images to be downloaded first before uploaded to jerking
	if [[ "${dlimages}" == "1" ]] && [[ "${scenepics}" != "" ]]; then
		writelog "Pre-downloading scene images..."
		echo "Pre-downloading scene images..."
		scenepics=$(downloadImages "${scenepics}")
		if [[ "$scenepics" == "" ]]; then
			writelog "Pre-downloading images failed, exiting"
			echo "Pre-downloading images failed, exiting"
			exit 1
		fi
	fi
	#function defined in <trackername>.sh
	if [[ "${scenepics}" != "" ]]; then
		writelog "Uploading scene images"
		echo "Uploading scene images"
	
		SCENE_IMAGES=$(uploadImages "${scenepicsoption}" "${scenepics}")
		if [[ "${SCENE_IMAGES}" == "" ]]; then
			writelog "Uploading scene images failed, exiting"
			echo "Uploading scene images failed, exiting"
			exit 1
		fi
	fi
fi
writelog "Images: ${SCENE_IMAGES}"

preloadedscreens=$(getPreloadedData "${releasesite}_${releasedate}_screens")
if [[ "${preloadedscreens}" != "" ]]; then
	SCENE_SCREENS="${preloadedscreens}"
else
	SCENE_SCREENS=$(uploadImages "-l" "${screens}")
	if [[ "${SCENE_SCREENS}" == "" ]]; then
		writelog "Uploading scene screens failed, exiting"
		echo "Uploading scene screens failed, exiting"
		exit 1
	fi
fi
writelog "Scene screens uploaded: $SCENE_SCREENS"
echo "Scene screens uploaded: $SCENE_SCREENS"

TORRENT_INPUT="${mediafile}"

#override this function to establish other merge variables, they should be named SCENE_SOMETHING for consistency
preMergeTemplate

template_str=$(cat "${presentationtemplate}")
presentationfile="${outbasefile}_presentation.txt"

writelog "Merging template '${presentationtemplate}' with data, saving to: '${presentationfile}'"
echo "Merging template '${presentationtemplate}' with data, saving to: '${presentationfile}'"
presentation=$(eval "echo \"${template_str}\"" > "${presentationfile}")

SCENE_TORRENT_TITLE=$(getTorrentTitle)
writelog "Torrent title: ${SCENE_TORRENT_TITLE}"
echo "Torrent title: ${SCENE_TORRENT_TITLE}"

writelog "Creating torrent, with the following params...)"
writelog "Input: ${TORRENT_INPUT}"
writelog "Output: ${torrentfilefolder}"
writelog "Announce url: ${announceurl}"

torrentfile=$(createTorrent "${TORRENT_INPUT}" "${torrentfilefolder}" "${announceurl}")
if [ ! -f "${torrentfile}" ]; then
	writelog "Creating torrent file failed, exiting"
	echo "Creating torrent file failed, exiting"
	exit 1
fi
writelog "Torrent file: ${torrentfile}"
echo "Torrent file: ${torrentfile}"

postMergeTemplate

deleteWorkingFiles

writelog "Done :)"
echo "Done :)"
