# Yet Another Splitter
## Purpose

Why do we need another splitter? Well, how about running binary scans on VMDK image or on a large disk image or a gigantic codebase?
We are talking tens of gigabytes and your scan limit is set to default 5 GB. No worries, this can help.

Some work would have to be done upfront. 

* Data that we scan would have to be presented as a filesystem.
* Individual files larger that the scan size limit will be excluded from the scan.
* If large files are archives, unravel them and discard archive file.
* A temporary location with enought storage to accept the dataset should be procured.

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
bash scanlargefolder.sh <PATH_TO_SOURCE_FOLDER> <PROJECT_NAME> <VERSION_NAME>

```
To run signature scan instead of binary scan run it as following:
```
bash scanlargefolder.sh <PATH_TO_SOURCE_FOLDER> <PROJECT_NAME> <VERSION_NAME> signature

```

## Docker Guide:

Build the container:

    docker build -t yasplitter-scanner:latest .

Create a secret for your API token.

    echo -n "your_token_here" | docker secret create bd_api_token -

Create a service that uses a mounted secret, mounting the large folder you wish to scan into the container.

    docker service create --name scanner \
      --secret source=bd_api_token,target=BD_API_TOKEN \
      -e BD_URL='https://your-blackduck.example' \
      -v /tmp/large_folder_to_scan:/large_folder_to_scan \
      yasplitter-scanner:latest /large_folder_to_scan PROJECT VERSION SUFFIX

Run a container with the secret:

    printf '%s' 'your_token_here' > /tmp/bd_token

    # run container and mount the file as /run/secrets/BD_API_TOKEN
    docker run --rm \
      -v /tmp/large_folder_to_scan:/large_folder_to_scan \
      -v /tmp/bd_token:/run/secrets/BD_API_TOKEN:ro \
      -e BD_URL='https://your-blackduck.example' \
      yasplitter-scanner:latest /tmp/myproject PROJECT VERSION SUFFIX