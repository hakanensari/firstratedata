#!/bin/bash

import_datasets ()
{
	while read dataset; do
		if [[ $dataset =~ /([[:alnum:]]+)- ]]; then
			account=${BASH_REMATCH[1]}
		else
			exit 1
		fi

		sed "s/^/$account,/" $dataset \
		| psql -c "COPY trades FROM STDIN CSV HEADER" $database_url
	done < <(find . -name "*.csv")
}

usage ()
{
	echo "usage: ingest [database_url]"
}

database_url=$1
if [[ -z $database_url || -n $2 ]]; then
	usage
	exit 1
fi

import_datasets
