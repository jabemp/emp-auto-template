#!/bin/bash

function uploadImages() {
	local opts="$1"
	local files="$2"
	local output=""
	IFS=' '
	for imgfile in $files
	do
		cmd="${imageuploadscript} ${opts} ${imgfile}"
		writelog "$cmd"
		scriptoutput=$(eval "$cmd")
		exitcode="$?"
		writelog "Imagescript exit code: ${exitcode}"
		if [ "${exitcode}" == "1" ] && [ "$scriptoutput" == "" ]; then
			writelog "Let's try that again..."
			sleep 2s
			scriptoutput=$(eval "$cmd")
			writelog "Imagescript exit code: ${exitcode}"
		fi
		writelog "Imagescript output: ${scriptoutput}"
		output+=" $scriptoutput"
		sleep 1s
	done
	unset IFS
	output=$(echo "$output" | sed -r 's/^\s+//g')
	echo "${output}"
}

function downloadImages() {
	local urls="$1"
	#urls=""
	IFS=' '
	local i=0
	local files=""
	
	for imgurl in $urls
	do
		(( i++ ))
		counter=$(printf "%02d" $i)
		filenamefromurl=$(echo "${imgurl##*/}" | sed 's/\?.*//g' | sed 's/ /%20/g')
		imagesource="${outbasefile}_${counter}_${filenamefromurl}"
		writelog "Downloading ${imgurl} to ${imagesource}"
		if [ -f "${imagesource}" ]; then
			rm "${imagesource}"
		fi
		cmd="curl -s -L -w %{http_code} -o $imagesource '$imgurl'"
		#writelog "$cmd"
		httpstatus=$(eval "$cmd")
		if [[ "${httpstatus}" == "200" ]] && [ -f "${imagesource}" ]; then
			writelog "download OK"
			files+=" ${imagesource}"
		else
			writelog "download FAILED!"
		fi
		#lets not spam the server...
		sleep 1s
	done
	unset IFS
	echo "$files"
}

function getAuthKey() {
	local tempfile=$(uuidgen | tr -d '-')
	local trash="$tempfolder/${tempfile}.htm"
	local res=$(curl -w %{http_code} -s -b "${trackercookiefile}" -c "${trackercookiefile}" -o "$trash" $trackeruploadurl)
	writelog "http code auth key: ${res}"
	local authkey=$(cat "$trash" | grep -Eo -m1 '"([a-f0-9]{32})"' | tr -d '"')
	writelog "auth key: ${authkey}"
	rm "$trash"
	echo "$authkey"
}
function addUploadConfig() {
	echo "$1" >> "${uploadconfig}"
}
function createUpload() {
	addUploadConfig "-L"
	addUploadConfig "--trace-ascii ${outbasefile}_upload_trace.log"
	addUploadConfig "url=${trackeruploadurl}"
	addUploadConfig "-b ${trackercookiefile}"
	addUploadConfig "-c ${trackercookiefile}"
	addUploadConfig "-F submit=true"
	authkey=$(getAuthKey)
	addUploadConfig "-F auth=${authkey}"
	addUploadConfig "-F file_input=@${torrentfile};type=application/x-bittorrent"
	addUploadConfig "-F category=${SCENE_CATEGORY}"
	addUploadConfig "-F \"taglist=${SCENE_TAGS}\""
	addUploadConfig "-F \"title=$SCENE_TORRENT_TITLE\""
	addUploadConfig "-F image=${SCENE_COVER}"
	addUploadConfig "-F desc=<${presentationfile}"
	addUploadConfig "-F anonymous=0"
}
function addTemplateConfig() {
	echo "$1" >> "${addtemplateconfig}"
}
function createTemplate() {
	addTemplateConfig "-L"
	addTemplateConfig "--trace-ascii ${outbasefile}_addtemplateconfig_trace.log"
	addTemplateConfig "url=${trackeruploadurl}?action=add_template"
	addTemplateConfig "-b ${trackercookiefile}"
	addTemplateConfig "-c ${trackercookiefile}"
	addTemplateConfig "-F templateID=0"
	addTemplateConfig "-F ispublic=0"
	addTemplateConfig "-F name=$1"
	addTemplateConfig "-F category=${SCENE_CATEGORY}"
	addTemplateConfig "-F \"tags=${SCENE_TAGS}\""
	addTemplateConfig "-F \"title=${SCENE_TORRENT_TITLE}\""
	addTemplateConfig "-F image=${SCENE_COVER}"
	addTemplateConfig "-F body=<${presentationfile}"
}

function checkLog() {
	:
}
#function addDupeCheckConfig() {
#	echo "$1" >> "$dupecheckconfig"
#}
#function dupeCheck() {
#	addDupeCheckConfig "-L"
#	addDupeCheckConfig "--trace-ascii $tempfolder/${outbasefile}_dupecheck_trace.log"
#	addDupeCheckConfig "url=$empuploadurl"
#	addDupeCheckConfig "-b $empcookiefile"
#	addDupeCheckConfig "-c $empcookiefile"
#	addDupeCheckConfig "-F submit=true"
#	authkey=$(getAuthKey)
#	addDupeCheckConfig "-F auth=$authkey"
#	addDupeCheckConfig "-F file_input=@${torrentfile};type=application/x-bittorrent"
#	addDupeCheckConfig "-F category=$category"
#	addDupeCheckConfig "-F \"checkonly=check for dupes\""
#	
#	local html="$tempfolder/${outbasefile}_dupecheck.html"
#	curl -s -K "$dupecheckconfig" -o "$html"
#	if grep -q 'The torrent contained one or more possible dupes' "$html" ; then
#		echo "1"
#	else
#		echo "0"
#	fi
#}

function upload() {
	writelog "Creating upload config..."
	createUpload
	local html="${outbasefile}_uploaded.html"
	curl -s -K "${uploadconfig}" -o "${html}"
	
	if [ ! -f "$html" ]; then
		writelog "Upload html file not found, exiting"
		echo "Upload html file not found, exiting"
		exit
	fi
	
	if grep -q 'The torrent contained one or more possible dupes' "$html" ; then
		echo "Dupe upload, we were too late ;("
		writelog "Dupe upload, we were too late ;("
		exit
	else
		dlurl=$(cat "$html" | grep -Eo -m1 '(torrents\.php\?action=download.[^"]+)' | sed -r 's/amp;//g')
		if [ "$dlurl" != "" ]; then
			dlurl="${trackerbaseurl}/$dlurl"
			dlfile=$(uuidgen | tr -d '-')
			dltorrentfile="${watchfolder}/${dlfile}.torrent"
			writelog "Torrent download url: ${dlurl}"
			writelog "Saving to: ${dltorrentfile}"
			res=$(curl -w %{http_code} -L -s -b "${trackercookiefile}" -c "${trackercookiefile}" --trace-ascii "${outbasefile}_download_trace.log" -o "${dltorrentfile}" "${dlurl}")
			if [[ "$res" != "200" ]]; then
				uploadfilename=$(basename $uploadconfig)
				writelog "Uploading template failed."
				writelog "Moving $uploadfilename to ${tempfolder}/failedtemplates/${uploadfilename}"
				mv "$uploadfilename" "${tempfolder}/failedtemplates/${uploadfilename}"
				
				presentationfilename=$(basename $presentationfile)
				writelog "Moving $presentationfile to ${tempfolder}/failedtemplates/${presentationfilename}"
				mv "$presentationfile" "${tempfolder}/failedtemplates/${presentationfilename}"
			else
				writelog "Deleting torrentfile: ${torrentfile}"
				rm "${torrentfile}"
			fi
		else
			echo "Torrent NOT uploaded, check file: ${outbasefile}_uploaded.html"
			writelog "Torrent NOT uploaded, check file: ${outbasefile}_uploaded.html"
		fi
	fi
}
function addTemplate() {
	#echo "Creating private template..."
	writelog "Creating private template..."
	createTemplate "${prefix}${releasesite,,}_${releasedate}"

	local html="${outbasefile}_addtemplate.html"

	echo "Uploading template..."
	writelog "Uploading template..."
	res=$(curl -w %{http_code} -s -k -K "$addtemplateconfig" -o "$html")
	writelog "http code from template upload: $res"
	if [[ "$res" != "200" ]]; then
		templatefilename=$(basename $addtemplateconfig)
		writelog "Uploading template failed."
		writelog "Moving $addtemplateconfig to ${tempfolder}/failedtemplates/${templatefilename}"
		mv "$addtemplateconfig" "${tempfolder}/failedtemplates/${templatefilename}"
		
		presentationfilename=$(basename $presentationfile)
		writelog "Moving $presentationfile to ${tempfolder}/failedtemplates/${presentationfilename}"
		mv "$presentationfile" "${tempfolder}/failedtemplates/${presentationfilename}"
	fi
}
