# Yet Another Splitter
## Purpose

Why do we need another splitter? Well, how about running binary scans on VMDK image or on a large disk image or a gigantic codebase?
We are talking tens of gigabytes and your scan limit is set to default 5 GB. No worries, this can help.

Some work would have to be done upfront. 

* Data that we scan would have to be presented as a filesystem.
* There should be no individual files larger that the scan size limit in that filestructure.
* If those are present, unravel them and discard archive file. If those are not archives - discard them.
* A temporary location with enought storage to accept the datatset should be procured.

Once that done, set the environment variables and scan.

## Quickstart Guide:

### Environment Variables
Set or export the following environment variables:

BD_URL -> https://<your_blackduck_url>

BD_API_TOKEN -> API token of the BD user

### Steps:

* Set the above referenced environment variables
* Place the data set into the source folder
  * Note the following:
      * If its an archive, please unpack it first
      * If its a mountable image file like vmdk, vhd, img or iso etc., please mount the image first and set the <PATH_TO_SOURCE_FOLDER> to the mount point
* Run the script as follows

```
bash binaryscanlargefolder.sh <PATH_TO_SOURCE_FOLDER> <PROJECT_NAME> <VERSION_NAME>

```
