#!/bin/bash
#


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
		stat -c%s $TEMPFILE
	else
		echo 0
	fi
}

SOURCEFOLDER=$1
PROJECT=$2
VERSION=$3
NOSCAN=$4


TEMPFOLDER=/extra/data/temp
FILELIST=$TEMPFOLDER/filelist
TMPLIST=$TEMPFOLDER/tmplist
TEMPFILE=$TEMPFOLDER/TEMP.tar
rm -f $TEMPFILE

SIZELIMIT=4000000000

#check if there are files larger that the limit

FILESOVERLIMIT=$(find $SOURCEFOLDER -type f -size +${SIZELIMIT})

if [ "$FILESOVERLIMIT" == "" ]
then
	echo No files larger that $SIZELIMIT detected. Proceeding
	echo
else
	echo 
	echo The following files are latger that $SIZELIMIT
	echo $FILESOVERLIMIT
	echo 
	echo Deal with them first.
	exit 1
fi

# Generate filelist
find $SOURCEFOLDER -type f -printf "%s %p \n" >$FILELIST

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
	PRETALLY=$(( $TOTAL + $SIZE ))
	if [ $PRETALLY -gt $SIZELIMIT ]
	then
		echo $TOTAL
		TOTAL=0
		tar cf $TEMPFOLDER/TEMP-${LINENUM}.tar -T $TMPLIST
		bash ../scan-binary.sh $TEMPFOLDER/TEMP-${LINENUM}.tar Hurt ${LINENUM}
		TOTAL=$SIZE
		echo $FPATH >$TMPLIST
	else
		TOTAL=$(( $TOTAL + $SIZE ))
		echo $FPATH >>$TMPLIST
	fi
done
echo $TOTAL
tar cf $TEMPFOLDER/TEMP-${LINENUM}.tar -T $TMPLIST
bash ../scan-binary.sh $TEMPFOLDER/TEMP-${LINENUM}.tar Hurt $(LINENUM)

exit 0 #This is the most important line
