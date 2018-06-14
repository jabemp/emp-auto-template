
scenepicsoption="-m"
dlimages="1"

function preMergeTemplate() {
	
	preloadedphotoset=$(getPreloadedData "${releasesite}_${releasedate}_photoset")
	if [[ "${preloadedphotoset}" != "" ]]; then
		photoset="${preloadedphotoset}"
	else
		photoset=$(getValueFromSceneFile "picsetCurl")
	fi
	
	
	if [[ "$photoset" != "" ]]; then
		
		scenetorrentfoldername=$(echo "${SCENE_SITENAME}_${SCENE_DATE}_${SCENE_TITLE}" | tr ' ' '-' | sed -r 's/[^a-z0-9_-]//gi')
		
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
		
		
		#creating config file for curl
		local tempbase=$(uuidgen | tr -d '-')
		local curlconfigpicset="${outbasefile}_${tempbase}_picset.cfg"
	
		local cmd="curl -s -k -L -O -K ${curlconfigpicset}"
	
		echo "--url ${photoset}" > "${curlconfigpicset}"
		echo "-A \"${useragent}\"" >> "${curlconfigpicset}"
		writelog "cURL: $cmd"
		#cd to picset path in new subshell and have curl save all images into that folder without changing current working folder
		resultcode=$(cd "${scenetorrentfolderpicpath}" && $cmd)
		writelog "Exit code from download: $?"
		picsetincluded="1"
		
		#movie movie file into new folder
		mv "${mediafile}" "${scenetorrentfolderpath}/"
		
		#set global torrent folder to new path that contains video & picset
		TORRENT_INPUT="${scenetorrentfolderpath}"
	else
		writelog "No photoset found"
	fi
}
