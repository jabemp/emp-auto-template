#!/bin/bash

if [[ "${releasesite,,}" == "fakedrivingschool" ]]; then
	indextablename="${releasesite,,}.xml"
	scenetablename="${releasesite,,}_scene.xml"
	scenetries=("titlematch like '%${releasecasttitle,,}%'")
fi

if [[ "${releasesite,,}" == "fakehostel" ]]; then
	indextablename="${releasesite,,}.xml"
	scenetablename="${releasesite,,}_scene.xml"
	scenetries=("date = '$releasedate'")
fi
