DROP TABLE IF EXISTS earnings CASCADE;

CREATE TABLE earnings (
	ticker TEXT NOT NULL,
	companyshortname TEXT,
	startdatetime TIMESTAMP NOT NULL,
	startdatetimetype TEXT NOT NULL,
	epsestimate DECIMAL,
	epsactual DECIMAL,
	epssurprisepct DECIMAL,
	timeZoneShortName TEXT NOT NULL,
	gmtOffsetMilliSeconds INTEGER NOT NULL,
	quoteType TEXT NOT NULL
);

CREATE INDEX earnings_ticker_idx ON earnings (ticker DESC);
