#!/bin/bash

function rawurlencode() {
	#http://stackoverflow.com/a/10660730
  local string="${1}"
  local strlen=${#string}
  local encoded=""

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )               printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
  echo "${encoded}"    # You can either set a return variable (FASTER) 
  REPLY="${encoded}"   #+or echo the result (EASIER)... or both... :p
  #easier:  echo http://url/q?=$( rawurlencode "$args" )
  #faster:  rawurlencode "$args"; echo http://url/q?${REPLY}
}

function runYqlQuery() {
	local query="${1}"
	local queryident="${2}"
	local outputfile="${outbasefile}_${queryident}.xml"
	local tracefile="${outbasefile}_${queryident}_trace.log"
	writelog "Using query: $query"
	
	local traceopts=""
	if [ "${enabletrace}" -eq "1" ]; then
		traceopts="--trace-ascii $tracefile"
	fi
	
	queryencoded=$(rawurlencode "$query")
	cmd="curl -s --write-out %{http_code} -o $outputfile $traceopts -G -d q=$queryencoded -d ${yqldebug} $yqlurl"
	writelog "cURL: $cmd"
	httpstatus=$($cmd)
	
	
	while grep -q "No definition found for Table" $outputfile;
	do 
		((c++)) && ((c==10)) && break
		writelog "YQL is unstable, retrying, attempt $c of 10"
		$(sleep 3)
		httpstatus=$($cmd)
	done	
	
	writelog "HTTP status: ${httpstatus}"
	echo "$outputfile"
}

function prepareYqlQuery() {
	local tablename="${1}"
	local criteria="${2}"
	local fulltableuri="${yqltablestore}/${tablename}"
	if [ "${cachebuster}" -eq "1" ]; then
		fulltableuri+="?t=${RANDOM}"
	fi
	local criteriaclause="where $criteria"
	if [[ "${criteria}" == "" ]]; then
		criteriaclause=""
	fi
	
	echo "use '${fulltableuri}' as index; select * from index $criteriaclause"
}

function downloadURLPhantomJS() {
	local reqOpts="$2"
	if [[ "$reqOpts" == "" ]]; then
		reqOpts="null"
	fi
	local request="{\"url\":\"$1\",\"renderType\":\"html\",\"outputAsJson\":false $2}"
	writelog "PJS params: ${request}"
	local encodedrequest=$(rawurlencode "$request")
	local pjsurl="https://PhantomJsCloud.com/api/browser/v2/${phantomjsAPIkey}/"
	
	local tempbase=$(uuidgen | tr -d '-')
	local tempfile="${tempbase}.htm"
	local outputfile="${localfolder}/${tempfile}"
	writelog "Saving $1 to ${outputfile} using PhantomJS"
	local tracefile="${outbasefile}_${tempbase}_trace.log"
	local traceopts=""
	if [ "${enabletrace}" -eq "1" ]; then
		traceopts="--trace-ascii $tracefile"
	fi

	cmdpjs="curl -s -k -w %{http_code} -o ${outputfile} ${traceopts} -G -d request=$encodedrequest $pjsurl"
	writelog "cURL: $cmdpjs"
	httpstatus=$($cmdpjs)
	writelog "HTTP status: ${httpstatus}"
	echo "${publicaddress}/${tempfile}"
}

#params: 1= url, 2=cookiedata
function downloadURL() {
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
	local cookiejar="${outbasefile}_${tempbase}_cookie.txt"
	local cmd="curl -s -k -L $traceopts -K ${curlconfig}"
	writelog "cURL: $cmd"
	echo "--url $1" > "${curlconfig}"
	echo "-w %{http_code}" >> "${curlconfig}"
	echo "-o ${outputfile}" >> "${curlconfig}"
	echo "-A \"${useragent}\"" >> "${curlconfig}"
	echo "-c ${cookiejar}" >> "${curlconfig}"
	if [[ "${2}" != "" ]] && [[ "${2}" == *"="* ]]; then
		echo "-b ${2}" >> "${curlconfig}"
	else
		echo "-b ${cookiejar}" >> "${curlconfig}"
	fi
	httpstatus=$($cmd)
	writelog "HTTP status: ${httpstatus}"
	echo "${publicaddress}/${tempfile}"
}

function getUrlFromSceneList() {
	scenelistfile="${1}"
	releasesite="${2}" 
	releasecasttitle="${3}"
	if [ ! -f "${scenelistfile}" ]; then
		writelog "Missing file: ${scenelistfile}"
		echo ""
		return 1
	fi
	local epurl=""
	xpath="scene"
	writelog "Evaluating scene list..."
	local count=$(xmllint --xpath "count(//${xpath})" $scenelistfile)
	writelog "Match count: ${count}"
	if [[ "${count}" == "1" ]]; then
		epurl=$(xmllint --xpath "string(//${xpath}/url/text())" $scenelistfile)
	elif [[ $count -gt 1 ]]; then
		writelog "Checking title match..."
		xpath="scene[contains('${releasecasttitle,,}',titlematch)]"
		count=$(xmllint --xpath "count(//${xpath})" $scenelistfile)
		if [[ "${count}" == "1" ]]; then
			writelog "Yes, we found a match based on title!"
			epurl=$(xmllint --xpath "string(//${xpath}/url/text())" $scenelistfile)
		fi
	fi
	echo "${epurl}"
}
