#!/bin/bash

import_datasets ()
{
	while read dataset; do
		cat $dataset \
		| psql -c "COPY earnings FROM STDIN CSV HEADER" $database_url
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
