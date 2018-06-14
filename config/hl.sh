
dlimages="1"
fakenetwork=1

function preMergeTemplate() {

	SCENE_LOGO=$(getLogo)
	
	if [[ "${releasesite,,}" == "holed" ]]; then
		SCENE_CATEGORY=2
	fi
	
}

function getLogo() {

	if [[ "${releasesite,,}" == "lubed" ]]; then
		echo "https://jerking.empornium.ph/images/2017/09/19/logo-8b83cd91c34ee89a2e0475c2586b273a.png"
	elif [[ "${releasesite,,}" == "holed" ]]; then
		echo "https://jerking.empornium.ph/images/2016/10/18/logo-59e39c0ee0aa363a180f047c70ef7c29.png"
	elif [[ "${releasesite,,}" == "nannyspy" ]]; then
		echo "https://jerking.empornium.ph/images/2017/10/17/logo-03f6fd8ee2155e1f688e4a8020dac8d7.png"
	elif [[ "${releasesite,,}" == "passion-hd" ]]; then
		echo "https://jerking.empornium.ph/images/2017/09/06/logo-fa043c73d898793b2053e83f3e87b80a.png"
	elif [[ "${releasesite,,}" == "spyfam" ]]; then
		echo "https://jerking.empornium.ph/images/2017/07/06/logo-aa95d8b3af58e06d360f0fa70c5ca335.png"
	elif [[ "${releasesite,,}" == "puremature" ]]; then
		echo "https://jerking.empornium.ph/images/2018/04/14/logo-a8d934c8b6fa608d435f35e4876fd0e9.png"
	fi
}
