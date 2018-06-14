siteparturl=$(echo "$releasesite" | sed -e 's/\([[:lower:]]\)\([[:upper:]]\)/\1\n\2/g' -e 's/\([[:upper:]]\+\)\([[:upper:]][[:lower:]]\)/\1\n\2/g' -e 's/_\+/\n/g' | tr '\n' '-' | sed -r 's/\-$//g' | tr '[:upper:]' '[:lower:]')

#Example: releasename=MySistersHotFriend.17.05.03.Christiana.Cinn.And.Jill.Kassidy.XXX.2160p.MP4-KTR

#We already have variable releasecasttitle that contains Christiana Cinn And Jill Kassidy
#Does a second name exists? If so, extract only first name
pornstardata="$releasecasttitle"
if echo "$pornstardata" | grep -q ' And ' ; then
	pornstardata=$(echo "$pornstardata" | grep -Po '(.+)(?= And)')
fi
pornstardata=$(echo "$pornstardata" | tr '. ' '--' | tr '[:upper:]' '[:lower:]')
#result: pornstardata=christiana-cinn

#special case
if [[ "$pornstardata" == "maddy-oreilly" ]] ; then
	pornstardata="maddy-o-reilly"
fi

scenetries[0]="site = '${siteparturl}' and date = '$releasedate' and pornstar='$pornstardata'"
scenetries+=("site = '${siteparturl}' and date = '$releasedate'")

function getTorrentTitle() {
	local PICSET=""
	if [[ "${picsetincluded}" == "1" ]]; then
		PICSET=" + PicSet"
	fi
	echo "[${SCENE_SITENAME_TITLE_CASE}] - ${SCENE_TITLE_CAST} (${SCENE_DATE}) [${SCENE_MEDIA_RESOLUTION_HEIGHT}]${PICSET}"
}
function downloadPhotoset() {
	local photoset=$(getValueFromSceneFile "photoset")
	
	if [[ "$photoset" != "" ]]; then
		
		scenetorrentfoldername=$(echo "${SCENE_SITENAME}_${SCENE_DATE}_${SCENE_TITLE_CAST}" | tr ' ' '-' | sed -r 's/[^a-z0-9_-]//gi')
		
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
		
	    local cmd="curl -s -k -K ${curlconfigpicset}"
	    filenamefromurl=$(echo "${photoset##*/}")
	    localzippath="${tempfolder}/${filenamefromurl}"
	    writelog "Downloading ${photoset} to ${localzippath}"
	    echo "--url ${photoset}" > "${curlconfigpicset}"
	    echo "-o ${localzippath}" >> "${curlconfigpicset}"
	    echo "-A \"${useragent}\"" >> "${curlconfigpicset}"
	    echo "-w %{http_code}" >> "${curlconfigpicset}"
	    writelog "cURL: $cmd"
	    
	    #cd to picset path in new subshell and have curl save all images into that folder without changing current working folder
	    resultcode=$($cmd)
	    writelog "http code: ${resultcode}"
		writelog "Exit code from download: $?"
		#movie movie file into new folder
		if [ -f "${localzippath}" ]; then
			unzip "${localzippath}" -d "${scenetorrentfolderpath}/PicSet"
			rm "${localzippath}"
			mv "${mediafile}" "${scenetorrentfolderpath}/"
			picsetincluded="1"
		fi

		#set global torrent folder to new path that contains video & picset
		TORRENT_INPUT="${scenetorrentfolderpath}"
	else
		writelog "No photoset found"
	fi
}
function preMergeTemplate() {
	downloadPhotoset
	SCENE_MAINIMAGE=$(echo "${SCENE_IMAGES}" | grep -Eo -m 1 'http.[^\[]+' | head -n 1)
	writelog "SCENE_MAINIMAGE=${SCENE_MAINIMAGE}"
}
