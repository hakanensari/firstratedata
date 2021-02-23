#!/bin/bash

download_files ()
{
	while read file_url; do
		if [[ $file_url =~ readme ]]; then
			continue
		fi
		curl $file_url -O -s &
	done < <(curl -s $download_url | egrep -o 'https://[[:graph:]]*aws[[:graph:]]*.zip')
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
