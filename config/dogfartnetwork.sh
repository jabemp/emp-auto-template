#!/bin/bash

scenetries[0]="site = '${releasesite}' and titlecompare = '${releasecasttitle,,}' and mode = 'parent'"

scenepicsoption="-m"
SCENE_CATEGORY=43
function getTorrentTitle() {
	local PICSET=""
	if [[ "${picsetincluded}" == "1" ]]; then
		PICSET=" + PicSet"
	fi
	echo "[${SCENE_SITENAME_TITLE_CASE}] - ${SCENE_CAST} (${SCENE_DATE}) [${SCENE_MEDIA_RESOLUTION_HEIGHT}]${PICSET}"
}

function downloadPhotoset() {
	
	preloadedphotoset=$(getPreloadedData "${releasesite}_${releasedate}_photoset")
	if [[ "${preloadedphotoset}" != "" ]]; then
		photoset="${preloadedphotoset}"
	else
		photoset=$(getValueFromSceneFile "photoset")
	fi
	
	if [[ "$photoset" != "" ]]; then
		
		scenetorrentfoldername=$(echo "${SCENE_SITENAME}_${SCENE_DATE}_${SCENE_CAST}" | tr ' ' '-' | sed -r 's/[^a-z0-9_-]//gi')
		
		#create new folder to contain video & picset
		scenetorrentfolderpath="${downloadfolder}/${scenetorrentfoldername}"
		if [ ! -d "${scenetorrentfolderpath}" ]; then
			writelog "Creating folder: ${scenetorrentfolderpath}"
			mkdir "${scenetorrentfolderpath}" 2>/dev/null
		fi
		
		#create picset path if not exists
		scenetorrentfolderpicpath="${scenetorrentfolderpath}/PicSet"
		if [ ! -d "${scenetorrentfolderpicpath}" ]; then
			writelog "Creating folder: ${scenetorrentfolderpicpath}"
			mkdir "${scenetorrentfolderpicpath}" 2>/dev/null
		fi
		
		if [ ! -d "${photoset}" ]; then
			local regex="(.*)\/(scenes|sites)\/([A-Za-z]+)\/([A-Z0-9a-z_]+)\/(.*)?"
			local site=$(echo "${photoset}" | sed -r "s/${regex}/\3/")
			local episode=$(echo "${photoset}" | sed -r "s/${regex}/\4/")
			local dirtocheck="${tempfolder}/PicSets/${site}_${episode}"
			writelog "Checking if picset is downloaded to $dirtocheck"
			if [ -d "${dirtocheck}" ]; then
				photoset="${dirtocheck}"
			fi
		fi
		
		
		
		if [ -d "${photoset}" ]; then
			writelog "Photoset is directory, moving ${photoset}/*.jpg to ${scenetorrentfolderpicpath}"
			mv "${photoset}/"*.jpg "${scenetorrentfolderpicpath}"
		else
			ua="Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"
			for x in {001..999}; do
				#already exists?
				if [ -f "${scenetorrentfolderpicpath}/$x.jpg" ]; then
					writelog "Image ${scenetorrentfolderpicpath}/$x.jpg already exists, skipping"
					continue
				fi
				url="${photoset}${x}.jpg"
				htmfile="${outbasefile}_${x}.htm"
				writelog "Fetching $url, saving to $htmfile"
				res=$(curl -w %{http_code} -s -A "\"${ua}\"" -L -o "${htmfile}" "$url")
				writelog "Result: $res"
			
				link=$(sed -n '/<img/s/.*src="\(https[^"]*\)".*/\1/p' $htmfile)
			
				writelog "Fetching image: $link, saving to ${scenetorrentfolderpicpath}/$x.jpg"
				rm "${htmfile}"
				if [[ "$link" == "" ]]; then
					writelog "Link not found, breaking loop"
					break
				fi
				res=$(curl -w %{http_code} -s -L -A "\"${ua}\"" -o "${scenetorrentfolderpicpath}/$x.jpg" "$link")
				writelog "Result: $res"
				if [[ "$res" != "200" ]]; then
					writelog "Breaking loop"
					rm "${scenetorrentfolderpicpath}/$x.jpg"
					break
				fi
			done
		fi
		
		
		
		mv "${mediafile}" "${scenetorrentfolderpath}/"
		picsetincluded="1"
		#set global torrent folder to new path that contains video & picset
		TORRENT_INPUT="${scenetorrentfolderpath}"
	else
		writelog "No photoset found"
	fi
}

function preMergeTemplate() {
	downloadPhotoset
}
