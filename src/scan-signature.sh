#!/bin/bash
#

PROJECTPATH=$1
PROJECT=$2
VERSION=$3
SUFFIX=$4

if [ "$PROJECTPATH" = "" ]
then
   echo "specify folder to scan"
   exit 1
fi

if [ "$PROJECT" = "" ] 
then
  PROJECT=${PROJECTPATH}
fi

if [ "$VERSION" = "" ]
then
  VERSION=LATEST
fi

# SET BD_URL and BD_API_TOKEN variables to point to your instance of Black Duck
#

bash <(curl -s -L https://detect.synopsys.com/detect8.sh) \
     --blackduck.url=$BD_URL \
     --blackduck.api.token=$BD_API_TOKEN \
     --blackduck.trust.cert=true \
     --detect.source.path=${PROJECTPATH} \
     --detect.tools=SIGNATURE_SCAN \
     --detect.project.name=${PROJECT} \
     --detect.project.version.name=${VERSION} \
     --detect.code.location.name=${PROJECT}_${VERSION}_${SUFFIX}_code \
