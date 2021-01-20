#!/bin/bash

download_files()
{
	while read url; do
		if [[ $url =~ readme ]]; then
			continue
		fi
		curl $url -O -s &
	done < <(curl -s $source | egrep -o 'https://[[:graph:]]*aws[[:graph:]]*.zip')
	wait
}

prepare_db()
{
	# Some datasets come with fractional values for volume, so for now, we're
	# defaulting to numeric type.
	psql -q $destination <<-SQL
		DROP TABLE IF EXISTS assets, indices;
		DROP TYPE IF EXISTS ASSET_TYPE;
		CREATE TYPE ASSET_TYPE AS ENUM ('stock', 'etf', 'future');
		CREATE TABLE IF NOT EXISTS assets (
			type ASSET_TYPE,
			symbol TEXT,
			datetime TIMESTAMP,
			open NUMERIC NOT NULL,
			high NUMERIC NOT NULL,
			low NUMERIC NOT NULL,
			close NUMERIC NOT NULL,
			volume NUMERIC NOT NULL
		);
		CREATE TABLE IF NOT EXISTS indices (
			symbol TEXT,
			datetime TIMESTAMP,
			open NUMERIC NOT NULL,
			high NUMERIC NOT NULL,
			low NUMERIC NOT NULL,
			close NUMERIC NOT NULL
		);
		DROP INDEX IF EXISTS assets_symbol_datetime_key, indices_symbol_datetime_key;
	SQL
}

import_data()
{
	while read collection; do
		if [[ $collection =~ usindex ]]; then
			table=indices
		elif [[ $collection =~ etf ]]; then
			table=assets
			type=etf
		elif [[ $collection =~ us_1500 ]]; then
			table=assets
			type=stock
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
			| if [[ $table == "assets" ]]; then sed "s/^/$type,$symbol,/"; else sed "s/^/$symbol,/"; fi \
			| psql -q -c "COPY $table FROM STDIN WITH (FORMAT CSV)" $destination
		done < <(unzip -Z1 $collection)
	done < <(find . -name "*.zip")
}

# This extra step cleans duplicate rows FirstRateData seems to occasionally
# introduce into its flat files.
#
# Consider the following if this approach is not efficient
# https://wiki.postgresql.org/wiki/Deleting_duplicates
delete_duplicates()
{
	for table in assets indices; do
		psql -q $destination <<-SQL
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

index_db()
{
	for table in assets indices; do
		psql -q -c "CREATE UNIQUE INDEX ${table}_symbol_datetime_key ON $table (symbol, datetime)" $destination
	done
}

usage()
{
	echo "usage: ingest [source] [destination]"
}
source=$1
destination=$2
if [[ -z $source || -z $destination || -n $3 ]]; then
	usage
	exit 1
fi

if [ `ls -1 *.zip 2>/dev/null | wc -l` == 0 ]; then
	download_files
fi
prepare_db
import_data
delete_duplicates
index_db
