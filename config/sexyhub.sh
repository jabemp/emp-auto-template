#!/bin/bash

if [[ "${releasesite,,}" == "fitnessrooms" ]]; then
	indextablename="${releasesite,,}.xml"
	scenetablename="${releasesite,,}_scene.xml"
	scenetries=("date = '$releasedate'")
fi
