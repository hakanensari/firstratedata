#!/bin/bash

download_files ()
{
	while read url; do
		file_url=$(curl -sI https://firstratedata.com/$url | grep -oE 'https://.*zip')
		# Skip files we're not interested in
		if [[ $file_url =~ futures|contracts ]]; then
			continue
		elif [[ $file_url =~ 5min|30min|1hour|UNADJUSTED ]]; then
			continue
		elif [[ $file_url =~ 2021 ]]; then
			continue
		fi
		curl -sO $file_url &
	done < <(curl -s $download_url | egrep -o '/datafile[^"]*')
	wait
}

usage ()
{
	echo "usage: download [download_url]"
}

download_url=$1
if [[ -z $download_url || -n $2 ]]; then
	usage
	exit 1
fi

download_files
