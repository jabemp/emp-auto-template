#!/bin/bash

SCENE_CATEGORY=17

scenetries[0]+=" and time='upcoming'"
scenetries+=("site = '${releasesite}' and time = 'current' and date = '${releasedate}'")
scenetries+=("site = 'all' and time = 'current' and date = '${releasedate}'")
