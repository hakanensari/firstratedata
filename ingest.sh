#!/bin/bash

truncate_tables ()
{
	psql -c "TRUNCATE TABLE stocks, etfs, indices" $database_url
}

drop_indices ()
{
	for table in stocks etfs indices; do
		psql -c "DROP INDEX IF EXISTS ${table}_symbol_datetime_idx" $database_url
		psql -c "DROP INDEX IF EXISTS ${table}_datetime_idx" $database_url
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
		else
			echo cannot parse $collection
			exit 1
		fi

		while read dataset; do
			if [[ $dataset =~ (^|[/_])([A-Z][0-9A-Z.]*)_ ]]; then
				symbol=${BASH_REMATCH[2]}
			else
				echo cannot parse $dataset
				exit 1
			fi

			unzip -p $collection $dataset \
			| sed "s/\r//" \
			| sed "/^$/d" \
			| sed "s/^/$symbol,/" \
			| timescaledb-parallel-copy -connection $database_url -workers 8 -table $table
		done < <(unzip -Z1 $collection)
	done < <(find . -name "*.zip")
}

add_indices ()
{
	for table in stocks etfs indices; do
		psql -c "CREATE INDEX ${table}_symbol_datetime_idx ON $table (symbol, datetime)" $database_url
		psql -c "CREATE INDEX ${table}_datetime_idx ON $table (datetime DESC)" $database_url
	done
	psql -c "ANALYZE" $database_url
}

refresh_materialized_views ()
{
	psql -c "REFRESH MATERIALIZED VIEW indices_1d" $database_url
	psql -c "REFRESH MATERIALIZED VIEW stocks_rth_1d" $database_url
	psql -c "REFRESH MATERIALIZED VIEW etfs_rth_1d" $database_url
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
add_indices
refresh_materialized_views
