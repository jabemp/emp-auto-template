#!/bin/bash

if [[ "${network}" != "" ]]; then
	networkconfig="${scriptsfolder}/${network,,}.sh"
	writelog "Checking network specific config..."
	if [ -f "${networkconfig}" ]; then
		writelog "Loading network specific config from '${networkconfig}'"
		echo "Loading network specific config from '${networkconfig}'"
		. "${networkconfig}"
	else
		writelog "No network config file found (this is not an error)"
	fi
fi

siteconfig="${scriptsfolder}/${releasesite,,}.sh"
writelog "Checking site specific config..."
if [ -f "${siteconfig}" ]; then
	writelog "Loading site specific config from '${siteconfig}'"
	echo "Loading site specific config from '${siteconfig}'"
	. "${siteconfig}"
else
	writelog "No site config file found (this is not an error)"
fi
