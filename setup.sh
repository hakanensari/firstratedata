#!/bin/bash

create_tables ()
{
	# Some datasets come with apparently-incorrect fractional values for volume,
	# so for now, I'm defaulting volume to numeric type.
	psql $database <<-SQL
		CREATE TABLE IF NOT EXISTS stocks (
			symbol TEXT,
			datetime TIMESTAMP,
			open NUMERIC NOT NULL,
			high NUMERIC NOT NULL,
			low NUMERIC NOT NULL,
			close NUMERIC NOT NULL,
			volume NUMERIC NOT NULL
		);
		CREATE TABLE IF NOT EXISTS etfs (
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
	SQL
}

usage ()
{
	echo "usage: setup [database]"
}

database=$1
if [[ -z $database || -n $2 ]]; then
	usage
	exit 1
fi

create_tables
