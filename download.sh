#!/bin/bash

download_files ()
{
	# Don't download again if files are already downloaded
	if [ `ls -1 *.zip 2>/dev/null | wc -l` == 0 ]; then
		while read file_url; do
			if [[ $file_url =~ readme ]]; then
				continue
			fi
			curl $file_url -O -s &
		done < <(curl -s $download_url | egrep -o 'https://[[:graph:]]*aws[[:graph:]]*.zip')
		wait
	fi
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
