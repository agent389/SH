#! /bin/bash
#
# lws-export.sh
#
# While this will export a Solr index based on a requested query it should be
# remembered that the results will change if items are being indexed into this
# collection at the same time as this is running. Probably shouldn't do that.
#
# Use this only for good.
#
# Carlos Valcarcel
# Created: 4/2/14
#
 
solrURL=http://localhost:8888/solr
collectionName=nutrition
# this can be either a comma separated list of field names or * to return all fields
fieldNames=id,title
maxDocumentsPerFile=2000
# this must be URL encoded. *%3A* is the equivalent of a full search using *:*
query=*%3A*
# a path would look like this using the following pieces where N is a number attached
# to the filename to make it unique:
# $destinationPath/$baseFilename-N.fileExtention
destinationPath=.
baseFilename=solr-export
# this can be xml,json or csv
# fileExtention=json
# outputFormat=json
# fileExtention=csv
# outputFormat=csv
fileExtention=xml
outputFormat=xml
 
#
# How many docs are there in total?
#
maxDocs=`curl "http://localhost:8888/solr/nutrition/select?q=$query&rows=0" | awk '/numFound=/{idx=index($0, "numFound="); totalDocs=substr($0,idx+10); idx=index(totalDocs,"\""); totalDocs=substr(totalDocs, 0, idx-1); print totalDocs}'`
 
echo "maxDocs: " $maxDocs
exit;
 
maxPageCount=$(($maxDocs/$maxDocumentsPerFile));
mod=$(($maxDocs % $maxDocumentsPerFile))
 
# might not have been a clean division. check if we have to do one last page check...
if [ $maxDocumentsPerFile -lt $maxDocs ]; then
  if [ $mod != 0 ]; then
    let maxPageCount=maxPageCount+1
  fi
fi
 
# echo "maxPageCount: " $maxPageCount
 
fileNumber=0
pageNumber=0
while [ $pageNumber -lt $maxPageCount ];
do
  offset=$(($pageNumber * $maxDocumentsPerFile))
  let fileNumber=fileNumber+1
  let pageNumber=pageNumber+1
 
  outputFilename=$destinationPath/$baseFilename-$fileNumber.$fileExtention
  echo "Writing file " $outputFilename
 
  echo curl "$solrURL/$collectionName/select?q=$query&wt=$outputFormat&indent=true&start=$offset&rows=$maxDocumentsPerFile&fl=$fieldNames"
  curl "$solrURL/$collectionName/select?q=$query&wt=$outputFormat&indent=true&start=$offset&rows=$maxDocumentsPerFile&fl=$fieldNames" > $outputFilename
done
