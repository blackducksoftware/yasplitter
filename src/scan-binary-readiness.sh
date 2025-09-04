#!/bin/bash
#

PROJECTPATH=$1
PROJECT=$2
VERSION=$3
SUFFIX=$4

DETECT_URL_PATH=https://detect.blackduck.com/detect${DETECT_MAJOR_VERSION:-10}.sh

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
get_bearer_token() {
    local response
    response=$(curl -s -X POST -H "Authorization: token $BD_API_TOKEN" "$BD_URL/api/tokens/authenticate")
    echo "$response" | grep -oP '"bearerToken"\s*:\s*"\K[^"]+'
}

get_scan_readiness() {
    local api_url="${BD_URL}/api/codelocations?q=name:${PROJECT}_${VERSION}_${SUFFIX}_code%20binary"
    echo "API URL: $api_url"
    local response
    local bearer_token=$(get_bearer_token)
    response=$(curl -s -H "Authorization: Bearer $bearer_token" "$api_url")
    echo "Response: $response"

    # Extract count of IN_PROGRESS status items
    local count
    count=$(echo "$response" | grep -o '"status":[^]]*' | grep -c 'IN_PROGRESS')
    echo "Count of IN_PROGRESS scans: $count"

    # Return 0 if no scans are in progress (ready), 1 otherwise (not ready)
    if [ "$count" -eq 0 ]; then
        echo "No scans in progress. Scan is ready."
        return 0
    else
        echo "Scans are still in progress."
        return 1
    fi
}

# bash <(curl -s -L $DETECT_URL_PATH) \
#      --blackduck.url=$BD_URL \
#      --blackduck.api.token=$BD_API_TOKEN \
#      --blackduck.trust.cert=true \
#      --detect.binary.scan.file.path=${PROJECTPATH} \
#      --detect.tools=BINARY_SCAN \
#      --detect.project.name=${PROJECT} \
#      --detect.project.version.name=${VERSION} \
#      --detect.code.location.name=${PROJECT}_${VERSION}_${SUFFIX}_code \

if [ "$DETECT_SERIAL_MODE" = "true" ] || [ "$DETECT_SERIAL_MODE" = "TRUE" ]; then
  # Wait for scan readiness
  echo "Waiting for scan readiness..."
  while ! get_scan_readiness; do
      echo "Scan is still in progress. Waiting 30 seconds before rechecking..."
      sleep 30
  done
  echo "Scan completed."
fi
