# Yet Another Splitter
## Purpose

Why do we need another splitter? Well, how about running binary scans on VMDK image or on a large disk image or a gigantic codebase?
We are talking tens of gigabytes and your scan limit is set to default 5 GB. No wories, this can help.

Some work would have to be done upfront. 

* Data that we scan would have to be presented as a filesystem.
* There should be no individual files larger that the scan size limit in that filestructure.
* If those are present, unravel them and discard archive file. If those are not archives - discard them.
* A temporary location with enought storage to accept the datatset should be procured.

Once that done, set the environment variables and scan.

## Environment Variables

## Notes
