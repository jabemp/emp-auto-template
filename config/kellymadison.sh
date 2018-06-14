SCENE_CATEGORY=37

epnum=$(echo "$releasedate" | sed -r 's/^E//g')
scenetries=("site = '${releasesite}' and (episode = '${epnum}' or date = '${releasedate}')")
