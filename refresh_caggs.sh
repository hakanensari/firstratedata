#!/bin/bash

refresh_caggs ()
{
	for interval in 5m 1h 1d; do
		for type in stocks_rth etfs_rth indexes; do
			psql -c "CALL refresh_continuous_aggregate('${type}_${interval}', NULL, NULL)" $database_url &
		done
		wait
	done
}

usage ()
{
	echo "usage: refress_caggs [database_url]"
}

database_url=$1
if [[ -z $database_url || -n $2 ]]; then
	usage
	exit 1
fi

refresh_caggs
