#!/bin/bash

install_dependencies()
{
	if ! command -v apt &> /dev/null; then
		apt install --yes \
			postgrsql-client \
			unzip
	fi
}

prepare_db()
{
	# Some datasets come with apparently-incorrect fractional values for volume,
	# so for now, I'm defaulting volume to numeric type.
	psql $database <<-SQL
		DROP TABLE IF EXISTS stocks, etfs, indices;
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

usage()
{
	echo "usage: setup [database]"
}

database=$1
if [[ -z $database || -n $2 ]]; then
	usage
	exit 1
fi

install_dependencies
prepare_db
