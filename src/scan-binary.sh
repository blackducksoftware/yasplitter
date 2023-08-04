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


export SPRING_APPLICATION_JSON='{"blackduck.url":$BD_URL,"blackduck.api.token":$BD_API_TOKEN}'
bash <(curl -s -L https://detect.synopsys.com/detect8.sh) \
     --blackduck.trust.cert=true \
     --detect.binary.scan.file.path=${PROJECTPATH} \
     --detect.tools=BINARY_SCAN \
     --detect.project.name=${PROJECT} \
     --detect.project.version.name=${VERSION} \
     --detect.code.location.name=${PROJECT}_${VERSION}_${SUFFIX}_code \
