#!/bin/bash

setup ()
{
	psql $database_url < sql/001_create_tables.sql
	psql $database_url < sql/002_create_views.sql
}

usage ()
{
	echo "usage: setup [database]"
}

database_url=$1
if [[ -z $database_url || -n $2 ]]; then
	usage
	exit 1
fi

setup
