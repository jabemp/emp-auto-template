# emp-auto-template

### Installation
* Download and extract, make sure folder structure is preserved. Open `config/settings.cfg` and review the variables needed. Make sure `scripts/maketemplate.sh` is executable: `chmod u+x maketemplate.sh`
* You need a torren create tool, the current implementation assumes you are using this tool : https://bitbucket.org/rsnitsch/py3createtorrent/downloads/. To use something different, make the necessary changes in `createtorrent.sh`
* To create screens you need Movie thumbnailer: http://moviethumbnail.sourceforge.net/ You will also need `tahomabd.ttf` font file, find it on Google. Put this font file in your mtn folder. (If you need 4K support use this instead https://github.com/thetmk/mtn/releases/tag/0.1 ) To use a total different tool, make the necessary changes in `createscreens.sh`
*
