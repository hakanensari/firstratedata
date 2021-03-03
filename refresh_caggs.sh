#!/bin/bash

refresh_caggs ()
{
	for view in stocks_5m_rth etfs_5m_rth indexes_5m stocks_1h_rth etfs_1h_rth indexes_1h stocks_1d_rth etfs_1d_rth indexes_1d; do
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
