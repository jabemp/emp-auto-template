### Features
* Matche scene release and episode metadata using YQL Open Data Tables.
* Unrar release.
* Create screens (contact sheet) of media file.
* Upload images to jerking image host.
* Create mediainfo report.
* Add and clean tags based on custom regexes.
* Create torrent file.
* Support for different templates for different sites by site name convention.
* Support for custom site handling (create gif cover, add photo set etc).
* Upload description as a private template with title, tags and cover (default) or direct upload.

### Prerequisites
* Linux environment with bash v4+, [xmllint](http://www.xmlsoft.org/downloads.html) and [mediainfo](https://mediaarea.net/en/MediaInfo).
* Python 3: https://www.python.org/downloads/ (Needed for image upload and torrent maker).
* Python packages 'Beautiful Soup' and 'requests', see `scripts/jerking_uploader.py` for more info. Make sure you can successfully upload a local image using this script on beforehand.

### Installation
* Download and extract, make sure folder structure is preserved. 
* Open `config/settings.cfg` and review the variables needed and their meaning.
* Make sure `scripts/maketemplate.sh` and `scripts/jerking_uploader.py` are executable: `chmod u+x <file>`.
* You need a torrent create tool, the current implementation assumes you are using this tool : https://bitbucket.org/rsnitsch/py3createtorrent/downloads/. To use something different, make the necessary changes in `createtorrent.sh`.
* To create screens you need Movie thumbnailer: http://moviethumbnail.sourceforge.net/ You will also need `tahomabd.ttf` font file, find it on Google. Put this font file in your mtn folder. (If you need 4K support use this instead https://github.com/thetmk/mtn/releases/tag/0.1 ) To use a total different tool, make the necessary changes in `createscreens.sh`

### Usage
Syntax: `./maketemplate.sh <path to release folder> [url to episode / scene]`
Example: `./maketemplate.sh ~/downloads/SomeAdultPaysite.18.01.01.Hot.Performer.XXX.1080p.MP4-GRP`
If core variables are misconfigured, the script should display an error message about the problem and exit. If second paramter `url` is supplied, any episode matching is skipped and the url will be used directly.

### Logging
A log file will be produced in your configured temp folder with name `<network>_<sitename>.log` or `<sitename>.log`

### Custom site handling
Scripts that matches `config/<network>.sh` or `config/<sitename>.sh` will be included into the main script. These scrips may override or contain custom functions to modify progam behaviour. Site specific scripts will take presedence over network specific scripts. See existing custom scripts in the `config` folder for examples.

#### Downloading images before uploading
Some paysites have query parameters in their image urls for a given scene, usually due to content protection measurements. The jerking image host does not support to load such url's directly, so instead they must be downloaded to your temporary folder first. To enable this functionality include variable `dlimages="1"` and it will be handled automatically.

#### Custom BB-code templates
To make network or site specific templates, please follow the following naming convention: `<network>_template.txt` or  `<sitename>_template.txt` Note: filenames must be all lower case. All templates should be stored in the `templates` folder.

#### Add more technical media info properties
See script `scripts/mediainfofuncs.sh` on how to extract more technical properties from the mediainfo report xml and assign them to global variables.

#### Overriding functions
Some functions in `corefuncs.sh` are encouraged to be overridden by a custom site config. These are:
* `preMergeTemplate`

This function can be used to have create additional variables with content referenced in your template definition BEFORE the actual merging and .torrent creation is done. Here you can create folder to include photoset or create .gif files from trailer or media file. Additional image upload must be handled in your function. If you need to change the source for torrent, set the variable `TORRENT_INPUT` to a custom folder. Default is the extracted media file.

* `getQueryOverrideParamsForSceneList` and `getQueryOverrideParamsForScene`

Here you can modify the input parameters for an YQL request to identify your episode or fetching episode metadata. This can for example include: 
- Downloading html via phantomjs from sites that heavily depends on javascript to be rendered completely.
- Fetch html from sites the require cookie and certain headers to be set.
You can then store the result on a public folder so that YQL can fetch the end result on your web server.

### Adding tables for new sites
Documentation on how to develop YQL Open Data Tables:
https://developer.yahoo.com/yql/guide/dev-external_tables.html
A custom table contains javascript code to parse html and build an xml response back with library E4X: https://developer.mozilla.org/en-US/docs/Archive/Web/E4X/Processing_XML_with_E4X

In order to add support for new site, you need two files, one yql table to list a site's episodes `<sitename>.xml` and one table to extract episode metadata (`<sitename>_scene.xml`)
The index table should return an xml strcture like this:
```
<results>
    <scene>
      <url>http://www.kinkysite.com/videos/ep/1234</url>
      <title>A Stepmom's Secrets</title>
      <titlematch>a stepmoms secrets</titlematch>
      <date>17.10.21</url>
    </scene>
    <scene>
    ...
    </scene>
</results>
```
The where-clause (ex: `select * from index where date = '17.10.21'`) in the query will hopefully narrow down the `scene`-list down to 1. This means we have a match between release and episode. It is also possible to match on title (from the title in the release name) agains element `titlematch` in the xml in case the episode list does not provide dates.

Here is an example with output from YQL response from a `<sitename>_scene.xml`:
```
<results>
  <scene>
    <title>A Stepmom's Secrets</title>
    <dateiso>2017-10-21</dateiso>
    <poster>http://www.kinkysite.com/videos/ep/1234/cover.jpg</poster>
    <images>
      <image>http://www.kinkysite.com/videos/ep/1234/preview1.jpg</image>
      <image>http://www.kinkysite.com/videos/ep/1234/preview2.jpg</image>
    </images>
    <cast>Cory Hunter, Mike Black &amp; Stephanie Swift</cast>
    <tags>Threesome, BJ, Hardcore</tags>
    <desc>Stepmom Cory catches her step daughter giving sloppy head to her bf, she decides to join in...</desc>
  </scene>
</results>
```

Please see existing custom tables to various sites as examples on how to develop your own.
