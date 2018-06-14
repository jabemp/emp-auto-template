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
* Make sure `scripts/maketemplate.sh` is executable: `chmod u+x maketemplate.sh`.
* You need a torrent create tool, the current implementation assumes you are using this tool : https://bitbucket.org/rsnitsch/py3createtorrent/downloads/. To use something different, make the necessary changes in `createtorrent.sh`.
* To create screens you need Movie thumbnailer: http://moviethumbnail.sourceforge.net/ You will also need `tahomabd.ttf` font file, find it on Google. Put this font file in your mtn folder. (If you need 4K support use this instead https://github.com/thetmk/mtn/releases/tag/0.1 ) To use a total different tool, make the necessary changes in `createscreens.sh`

### Usage
`./maketemplate.sh ~/downloads/SomeAdultPaysite.18.01.01.Hot.Performer.XXX.1080p.MP4-GRP`

If core variables are misconfigured, the script should display an error message about the problem and exit.

