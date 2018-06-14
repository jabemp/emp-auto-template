teamskeeturl="http://teamskeet.com/t1/updates/load?view=newest&fltrs[tags]=&fltrs[site]=ALL&page=1&changedOrder=0&fltrs[tags]=&fltrs[time]=ALL&fltrs[site]=ALL&order=DESC&tags_select=&fltrs[title]="

#params: 1= url, 2=cookiedata
function downloadURLCustom() {
	local tempbase=$(uuidgen | tr -d '-')
	local tempfile="${tempbase}.htm"
	local outputfile="${localfolder}/${tempfile}"
	writelog "Saving $1 to ${outputfile}"
	local tracefile="${outbasefile}_${tempbase}_trace.log"
	local traceopts=""
	if [ "${enabletrace}" -eq "1" ]; then
		traceopts="--trace-ascii $tracefile"
	fi
	local curlconfig="${outbasefile}_${tempbase}.cfg"
	local cmd="curl -s -k -L $traceopts -K ${curlconfig}"
	writelog "cURL: $cmd"
	echo "--globoff" > "${curlconfig}"
	echo "--url $1" >> "${curlconfig}"
	echo "-H \"X-Requested-With: XMLHttpRequest\"" >> "${curlconfig}"
	echo "-w %{http_code}" >> "${curlconfig}"
	echo "-e http://teamskeet.com/t1/updates/?site=ts" >> "${curlconfig}"
	echo "-o ${outputfile}" >> "${curlconfig}"
	echo "-A \"${useragent}\"" >> "${curlconfig}"
	if [[ "${2}" != "" ]]; then
		echo "-b ${2}" >> "${curlconfig}"
	fi
	httpstatus=$($cmd)
	#local outf=$(downloadUrlFromPJS "$1" "${outputfile}")
	writelog "Result: ${httpstatus}"
	echo "${publicaddress}/${tempfile}"
}

function downloadURLSceneCustom() {
	local tempbase=$(uuidgen | tr -d '-')
	local tempfile="${tempbase}_scene.htm"
	local outputfile="${localfolder}/${tempfile}"
	writelog "Saving $1 to ${outputfile}"
	local tracefile="${outbasefile}_${tempbase}_scene_trace.log"
	local cookiefile="${outbasefile}_${tempbase}_scene_cookie.txt"
	local traceopts=""
	if [ "${enabletrace}" -eq "1" ]; then
		traceopts="--trace-ascii $tracefile"
	fi
	local curlconfig="${outbasefile}_${tempbase}_scene.cfg"
	local cmd="curl -s -k -L $traceopts -K ${curlconfig}"
	writelog "cURL: $cmd"
	echo "--globoff" > "${curlconfig}"
	echo "--max-redirs 3" > "${curlconfig}"
	echo "--url ${1}&type=hi_res&trailer=a" >> "${curlconfig}"
	echo "-w %{http_code}" >> "${curlconfig}"
	echo "-e http://teamskeet.com/t1/updates/?site=ts" >> "${curlconfig}"
	echo "-o ${outputfile}" >> "${curlconfig}"
	echo "-A \"${useragent}\"" >> "${curlconfig}"
	echo "-H Accept: text/html" >> "${curlconfig}"
	echo "-b TST1trailerVersion=a; TST1trailerResolution=hi" >> "${curlconfig}"
	echo "-c ${cookiefile}" >> "${curlconfig}"
	httpstatus=$($cmd)
	#local outf=$(downloadUrlFromPJS "$1" "${outputfile}")
	writelog "Result: ${httpstatus}"
	echo "${publicaddress}/${tempfile}"
}

function getQueryOverrideParamsForSceneList() {
	local fetchurl="${teamskeeturl}"
	local dateparam="${2}"
	local remoteurl=$(downloadURLCustom "${fetchurl}")
	echo "remoteurl = '${remoteurl}' and date = '${dateparam}'"
}

function getQueryOverrideParamsForScene() {
	writelog "overriding yql params..."
	local fetchurl="${1}"
	local remoteurl=$(downloadURLSceneCustom "${fetchurl}")
	echo "url = '${remoteurl}'"
}

