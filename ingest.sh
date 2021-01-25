#!/bin/bash

truncate_tables ()
{
	# Some datasets come with apparently-incorrect fractional values for volume,
	# so for now, I'm defaulting volume to numeric type.
	psql -c "TRUNCATE TABLE stocks, etfs, indices" $database
}

drop_indices ()
{
	for table in stocks etfs indices; do
		psql -c "DROP INDEX IF EXISTS ${table}_symbol_datetime_key" $database
	done
}

# This extra step cleans duplicate rows FirstRateData seems to occasionally
# introduce into its flat files.
delete_duplicates ()
{
	for table in stocks etfs indices; do
		psql $database <<-SQL
			DELETE FROM $table a USING (
				SELECT MIN(ctid) as ctid, symbol, datetime
					FROM $table
					GROUP BY symbol, datetime
					HAVING COUNT(*) > 1
				) b
				WHERE a.symbol = b.symbol
				AND a.datetime = b.datetime
				AND a.ctid <> b.ctid
		SQL
	done
}


add_indices ()
{
	for table in stocks etfs indices; do
		psql -c "CREATE UNIQUE INDEX ${table}_symbol_datetime_key ON $table (symbol, datetime)" $database
	done
}

download_files ()
{
	# Don't download again if files are already downloaded
	if [ `ls -1 *.zip 2>/dev/null | wc -l` == 0 ]; then
		while read url; do
			if [[ $url =~ readme ]]; then
				continue
			fi
			curl $url -O -s &
		done < <(curl -s $web | egrep -o 'https://[[:graph:]]*aws[[:graph:]]*.zip')
		wait
	fi
}

import_datasets ()
{
	while read collection; do
		if [[ $collection =~ us_1500 ]]; then
			table=stocks
		elif [[ $collection =~ etf ]]; then
			table=etfs
		elif [[ $collection =~ usindex ]]; then
			table=indices
		elif [[ $collection =~ futures || $collection =~ contracts ]]; then
			# TODO: Skip futures for now
			continue
		else
			exit 1
		fi

		while read dataset; do
			# TODO: Confirm this correctly extracts all symbols
			if [[ $dataset =~ (^|/)([A-Z][0-9A-Z.]*)_ ]]; then
				symbol=${BASH_REMATCH[2]}
			else
				exit 1
			fi

			unzip -p $collection $dataset \
			| sed "s/\r//" \
			| sed "/^$/d" \
			| sed "s/^/$symbol,/" \
			| psql -c "COPY ${table} FROM STDIN WITH (FORMAT CSV)" $database
		done < <(unzip -Z1 $collection)
	done < <(find . -name "*.zip")
}

usage ()
{
	echo "usage: ingest [web] [database]"
}

web=$1
database=$2
if [[ -z $web || -z $database || -n $3 ]]; then
	usage
	exit 1
fi

download_files
truncate_tables
drop_indices
import_datasets
delete_duplicates
add_indices
