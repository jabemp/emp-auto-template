#!/bin/bash

function getValueFromKeyInFile() {
	if [ ! -f "${1}" ] || [ "${2}" == "" ]; then
		echo ""
		return 1
	fi
	#echo "before loop" 
	local values=""
	while read currentline; do
		#ignore lines starting with semicolon ; or hashtags #, they are usually just comments
		if echo "$currentline" | grep -q "^[;#]" ; then
			continue
		fi
		#extract key from left side of equal sign and trim leading and trailing space
	  	local key=$(echo "${currentline}" | awk -F "=" '{print $1}' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
	  	#echo "current key: $key"
	  	#comare current key with given in lower case
	  	if [[ "${key,,}" == "${2,,}" ]]; then
	  		values=$(echo "${currentline}" | awk -F "=" '{print $2}')
	  		break
	  	fi
	done < "$1"
	#echo "after loop, returning..."
	echo "$values"	
}

function getKeyFromValueInFile() {
	local inputfile="${1}"
	if [ ! -f "${inputfile}" ]; then
		echo ""
		return 1
	fi
	
	local key=""
	while read currentline; do
		#get all values on right side of equal sign
		if echo "$currentline" | grep -q "^[;#]" ; then
			continue
		fi
	  	local values=$(echo "${currentline}" | awk -F "=" '{print $2}')
	  	
	  	#read values into new array by splitting all values on comma
	  	IFS=',' read -ra VALUESARRAY <<< "${values}"
		for i in "${VALUESARRAY[@]}"; do
			#trim current value from leading/trailing spaces
			i=$(echo "${i}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
			#compare current value with given value in lower case
			if [[ "${i,,}" == "${2,,}" ]]; then
				#get value from left side of equal sign and trim leading/trailing spaces
	  			key=$(echo "${currentline}" | awk -F "=" '{print $1}' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
	  			break
	  		fi
	  		#if key has been set, exit loop
	  		if [[ "${key}" != "" ]]; then
	  			break
	  		fi
		done
	done < "${inputfile}"
	unset IFS
	
	echo "${key}"	
}
