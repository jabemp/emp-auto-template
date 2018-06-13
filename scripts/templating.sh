#!/bin/bash

networktemplate="${templatefolder}/${network,,}_template.txt"
if [ "${network}" != "" ] && [ -f "${networktemplate}" ]; then
	presentationtemplate="${networktemplate}" 
fi

sitetemplate="${templatefolder}/${releasesite,,}_template.txt"
if [ -f "${sitetemplate}" ]; then
	presentationtemplate="${sitetemplate}" 
fi
