#!/bin/bash

refresh_caggs ()
{
	for view in stocks_rth_5m etfs_rth_5m indexes_5m stocks_rth_1h etfs_rth_1h indexes_1h stocks_rth_1d etfs_rth_1d indexes_1d; do
		psql -c "CALL refresh_continuous_aggregate('$view', NULL, NULL)" $database_url
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
