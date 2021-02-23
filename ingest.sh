#!/bin/bash

truncate_tables ()
{
	psql -c "TRUNCATE TABLE stocks, etfs, indices" $database_url
}

drop_indices ()
{
	for table in stocks etfs indices; do
		psql -c "DROP INDEX IF EXISTS ${table}_symbol_datetime_key" $database_url
	done
}

import_datasets ()
{
	while read collection; do
		if [[ $collection =~ us1500 ]]; then
			table=stocks
		elif [[ $collection =~ etf ]]; then
			table=etfs
		elif [[ $collection =~ usindex ]]; then
			table=indices
		elif [[ $collection =~ futures || $collection =~ contracts ]]; then
			# TODO: Skip futures for now
			continue
		else
			echo cannot parse $collection
			exit 1
		fi

		while read dataset; do
			# TODO: Confirm this correctly extracts all symbols
			if [[ $dataset =~ (^|/)([A-Z][0-9A-Z.]*)_ ]]; then
				symbol=${BASH_REMATCH[2]}
			else
				echo cannot parse $dataset
				exit 1
			fi

			unzip -p $collection $dataset \
			| sed "s/\r//" \
			| sed "/^$/d" \
			| sed "s/^/$symbol,/" \
			| psql -c "COPY ${table} FROM STDIN WITH (FORMAT CSV)" $database_url
		done < <(unzip -Z1 $collection)
	done < <(find . -name "*.zip")
}


# This extra step cleans duplicate rows FirstRateData seems to occasionally
# introduce into its flat files.
delete_duplicates ()
{
	for table in stocks etfs indices; do
		psql $database_url <<-SQL
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
		psql -c "CREATE UNIQUE INDEX ${table}_symbol_datetime_key ON $table (symbol, datetime)" $database_url
	done
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

truncate_tables
drop_indices
import_datasets
delete_duplicates
add_indices
