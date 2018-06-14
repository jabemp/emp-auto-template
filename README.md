### Features
* Matches scene release and episode metadata using YQL custom tables.
* Unpacks release.
* Create screens (contact sheet) of media file.
* Uploads images to jerking image host.
* Create mediainfo report.
* Adds and cleans tags based on custom regexes.
* Creates torrent file.
* Supports different templates for different sites by site name convention.
* Supports custom site handling (create gif cover, add photo set etc).
* Uploads description as a private template (default) or direct upload.

### Prerequisites
* Linux environment with bash v4+, [xmllint](http://www.xmlsoft.org/downloads.html) and [mediainfo](https://mediaarea.net/en/MediaInfo).
* Python 3: https://www.python.org/downloads/ (Needed for image upload and torrent maker).
* Python packages 'Beautiful Soup' and 'requests', see `scripts/jerking_uploader.py` for more info. Make sure you can successfully upload a local image using this script on beforehand.

### Installation
* Download and extract, make sure folder structure is preserved. 
* Open `config/settings.cfg` and review the variables needed. 
* Make sure `scripts/maketemplate.sh` and `scripts/jerking_uploader.py` are executable: `chmod u+x <file>`.
* You need a torrent create tool, the current implementation assumes you are using this tool : https://bitbucket.org/rsnitsch/py3createtorrent/downloads/. To use something different, make the necessary changes in `createtorrent.sh`.
* To create screens you need Movie thumbnailer: http://moviethumbnail.sourceforge.net/ You will also need `tahomabd.ttf` font file, find it on Google. Put this font file in your mtn folder. (If you need 4K support use this instead https://github.com/thetmk/mtn/releases/tag/0.1 ) To use a total different tool, make the necessary changes in `createscreens.sh`

### Usage
Syntax: `./maketemplate.sh ~/downloads/SomeAdultPaysite.18.01.01.Hot.Performer.XXX.1080p.MP4-GRP [url to episode / scene]` 
If core variables are misconfigured, the script should display an error message about the problem and exit. Also, check logfile produced in your temp-folder. If second paramter `url` is supplied, any episode matching is skipped and the url will be used directly.

### Custom site handling
Scripts that matches `<network>.sh` or `<sitename>.sh` will be included into the main script. These scrips may override or contain custom functions to modify progam behaviour.

#### Downloading images before uploading
Some paysites have query parameters in their image urls for a given scene, usually due to content protection measurements. The jerking image host does not support to load such url's directly, so instead they must be downloaded to your temporary folder first. To enable this functionality include variable `dlimages="1"` and it will be handled automatically.

#### Custom BB-code templates
To make network or site specific templates, please follow the following naming convention: `<network>_template.txt` or  `<sitename>_template.txt` Note: filenames must be all lower case. All templates should be stored in the `templates` folder.

#### Overriding functions
Some functions in `corefuncs.sh` are encouraged to be overridden by a custom site config. These are:
* `preMergeTemplate`

This function can be used to have create additional variables with content referenced in your template definition BEFORE the actual merging and .torrent creation is done. Here you can create folder to include photoset or create .gif files from trailer or media file. Additional image upload must be handled in your function. If you need to change the source for torrent, set the variable `TORRENT_INPUT` to a custom folder. Default is the extracted media file.

* `getQueryOverrideParamsForSceneList` and `getQueryOverrideParamsForScene`

Here you can modify the input parameters for an YQL request to identify your episode or fetching episode metadata. This can for example include: 
- Downloading html via phantomjs from sites that heavily depends on javascript to be rendered completely.
- Fetch html from sites the require cookie and certain headers to be set.
You can then store the result on a public folder so that YQL can fetch the end result on your web server.


