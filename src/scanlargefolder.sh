#!/bin/bash
# Copyright (c) 2023 - Synopsys, Inc.
# Author: MK
# 
# Purpose - File based splitter for BINARY and SIGNATURE scans
# This script will scan a large filesystem in chunks no larger than $SIZELIMIT. 
# Directory structure can be arbitrary
#
# ** Data that we scan would have to be presented as a filesystem (folder).
# ** Individual files larger that the scan size limit will be excluded from the scan.
# ** If large files are archives, unravel them and discard archive file.
# ** A temporary location with enough storage to accept the entire dataset needed.
#
#
#  usage:
#  bash scanlargefolder.sh <PATH_TO_SOURCE_FOLDER> <PROJECT_NAME> <VERSION_NAME> [sig]
#  PATH_TO_SOURCE_FOLDER - Location to be scanned
#  PROJECT_NAME          - Project Name
#  VERSION_NAME          - Version Name
#  sig, optional         - If present use signature scan instaed of binary scan
#

function usage() {
  echo
  echo "usage:"
  echo "bash scanlargefolder.sh PATH_TO_SOURCE_FOLDER PROJECT_NAME VERSION_NAME [sig]"
  echo "  PATH_TO_SOURCE_FOLDER - Location to be scanned"
  echo "  PROJECT_NAME          - Project Name"
  echo "  VERSION_NAME          - Version Name"
  echo "  sig, optional         - If present use signature scan instaed of binary scan"
  echo
}


function calculate_size()
{
	cat $1 | \
	awk '{printf "%s+", $1}' | \
	awk '{print $0 "0"}'  | \
	bc -l
}

function file_size_or_zero()
{ 
	if [ -f "$1" ]
	then
		stat -c%s $1
	else
		echo 0
	fi
}

SOURCEFOLDER=$1
PROJECT=$2
VERSION=$3
SCANMODE=$4

# Validate command line parameters
if [ $# -lt 3 ]
then
	usage
	exit
fi

# Validate target folder

if [ ! -d "$SOURCEFOLDER" ]
then
	echo Folder $SOURCEFOLDER Does not exist
	echo
	exit 1
fi

# Setup tempspace
TEMPFOLDER=~/temp
mkdir -p $TEMPFOLDER
FILELIST=$TEMPFOLDER/filelist
TMPLIST=$TEMPFOLDER/tmplist
rm -rf $TEMPFOLDER/TEMP*
rm -f $FILELIST
rm -f $TMPLIST
# Print info on available space
TEMPSPACE=$(df -h $TEMPFOLDER | grep -vi size | awk '{print $4}')
echo Available space in TEMPFOLDER $TEMPSPACE

# Max chunk size limit
SIZELIMIT=4000000000

# Environment and other sanity checks 
# check if we have GNU find
find --version >/dev/null 2>&1
if [ "$?" == "0" ]
then 
	echo Found GNU find
else
	echo Need GNU find
	exit 1
fi

# Check if we have BD_URL
if [ -n "$BD_URL" ]
then
	echo Blackduck is at $BD_URL
else
	echo need BD_URL
	exit 1
fi

# Check if we have API TOKEN
if [ -n "$BD_API_TOKEN" ]
then
	echo Found BD_API_TOKEN
else
	echo need BD_API_TOKEN
	exit 1
fi

DETECT_VERSION=0
if [ -n "$DETECT_MAJOR_VERSION" ]
then
	echo Detect Major Version is $DETECT_MAJOR_VERSION
	DETECT_VERSION = $DETECT_MAJOR_VERSION
 else
 	echo Detect Version 9 will be used
  	DETECT_VERSION = 9
fi

#
#check if there are files larger than the limit
FILESOVERLIMIT=$(find $SOURCEFOLDER -type f -size +${SIZELIMIT}c)

if [ "$FILESOVERLIMIT" == "" ]
then
	echo No files larger that $SIZELIMIT detected. Proceeding
	echo
else
	echo 
	echo The following files are larger than $SIZELIMIT
	echo $FILESOVERLIMIT
	echo 
	echo They will be excluded from processing.
fi

# Generate filelist
find $SOURCEFOLDER -type f -printf "%s %p \n" >$FILELIST

if [ ! -s $FILELIST ]
then
	echo "No files found in the target folder."
	exit 1
fi

#Basic stats
TOTALSIZE=$(calculate_size $FILELIST)
NUMFILES=$(cat $FILELIST | wc -l)

echo $NUMFILES files totaling $TOTALSIZE bytes
echo
echo Processing filelist

TOTAL=0
LINENUM=0
cat $FILELIST | while read LINE
do
	LINENUM=$(( $LINENUM + 1 ))
	DATA=($LINE)
	SIZE=${DATA[0]}
	FPATH=${LINE/$SIZE /}
	if [ $SIZE -gt $SIZELIMIT ]
	then
		continue
	fi
	PRETALLY=$(( $TOTAL + $SIZE ))
	if [ $PRETALLY -gt $SIZELIMIT ]
	then
		echo $TOTAL
		TOTAL=0
		mkdir -p $TEMPFOLDER/TEMP-${LINENUM}
		tar cf $TEMPFOLDER/TEMP-${LINENUM}/TEMP-${LINENUM}.tar -T $TMPLIST
		if [ "$SCANMODE" == "" ]
		then
			bash scan-binary.sh $TEMPFOLDER/TEMP-${LINENUM}/TEMP-${LINENUM}.tar $PROJECT $VERSION ${LINENUM}
		else
			bash scan-signature.sh $TEMPFOLDER/TEMP-${LINENUM} $PROJECT $VERSION ${LINENUM}
		fi
		TOTAL=$SIZE
		echo $FPATH >$TMPLIST
	else
		TOTAL=$(( $TOTAL + $SIZE ))
		echo $FPATH >>$TMPLIST
	fi
done
echo $TOTAL
mkdir -p $TEMPFOLDER/TEMP-${LINENUM}
tar cf $TEMPFOLDER/TEMP-${LINENUM}/TEMP-${LINENUM}.tar -T $TMPLIST
if [ "$SCANMODE" == "" ]
then    
	bash scan-binary.sh $TEMPFOLDER/TEMP-${LINENUM}/TEMP-${LINENUM}.tar $PROJECT $VERSION ${LINENUM} $DETECT_VERSION
else    
	bash scan-signature.sh $TEMPFOLDER/TEMP-${LINENUM} $PROJECT $VERSION ${LINENUM} $DETECT_VERSION
fi      

if [ "$FILESOVERLIMIT" == "" ]
then
        echo No files larger that $SIZELIMIT detected. 
	echo
else
        echo 
        echo The following files are larger than $SIZELIMIT
        echo $FILESOVERLIMIT
        echo 
        echo They were excluded from processing.
fi
echo

exit 0 #This is the most important line
