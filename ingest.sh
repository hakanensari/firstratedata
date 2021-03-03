#!/bin/bash

drop_indexes ()
{
	for table in stocks_1m etfs_1m indexes_1m; do
		psql -c "DROP INDEX ${table}_datetime_idx" $database_url
		psql -c "DROP INDEX ${table}_symbol_datetime_idx" $database_url
	done
}

import_datasets ()
{
	cd data
	while read collection; do
		if [[ $collection =~ us1500 ]]; then
			table=stocks_1m
		elif [[ $collection =~ etf ]]; then
			table=etfs_1m
		elif [[ $collection =~ usindex ]]; then
			table=indexes_1m
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

create_indexes ()
{
	for table in stocks_1m etfs_1m indexes_1m; do
		psql -c "CREATE INDEX ${table}_datetime_idx ON $table (datetime DESC)" $database_url
		psql -c "CREATE INDEX ${table}_symbol_datetime_idx ON $table (symbol, datetime DESC)" $database_url
	done
}

analyze ()
{
	psql -c "ANALYZE" $database_url
}

compress_chunks ()
{
	for table in stocks_1m etfs_1m indexes_1m; do
		psql $database_url <<-SQL
			SELECT
				compress_chunk(chunk)
			FROM (
				SELECT concat(chunk_schema, '.', chunk_name)::regclass AS chunk
				FROM chunk_compression_stats('$table')
				WHERE compression_status != 'Compressed'
				INTERSECT
				SELECT
					show_chunks('$table', older_than => interval '1 week')
			) AS chunk
		SQL
	done
}

refresh_caggs ()
{
	./refresh_caggs.sh $database_url
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

drop_indexes
import_datasets
create_indexes
analyze
compress_chunks
refresh_caggs
