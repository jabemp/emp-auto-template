# emp-auto-template

### Installation
* Python 3 is required to be installed: https://www.python.org/downloads/
* Python packages 'Beautiful Soup' and 'requests' needs to be installed, see `scripts/jerking_uploader.py` for more info
* Download and extract, make sure folder structure is preserved. 
* Open `config/settings.cfg` and review the variables needed. 
* Make sure `scripts/maketemplate.sh` is executable: `chmod u+x maketemplate.sh`
* You need a torrent create tool, the current implementation assumes you are using this tool : https://bitbucket.org/rsnitsch/py3createtorrent/downloads/. To use something different, make the necessary changes in `createtorrent.sh`
* To create screens you need Movie thumbnailer: http://moviethumbnail.sourceforge.net/ You will also need `tahomabd.ttf` font file, find it on Google. Put this font file in your mtn folder. (If you need 4K support use this instead https://github.com/thetmk/mtn/releases/tag/0.1 ) To use a total different tool, make the necessary changes in `createscreens.sh`

### Usage
`./maketemplate.sh ~/downloads/SomeAdultPaysite.18.01.01.Hot.Performer.XXX.1080p.MP4-GRP`
If core variables are misconfigured, the script should display an error message about the problem and exit.
