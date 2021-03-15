DROP TABLE IF EXISTS earnings CASCADE;

CREATE TABLE earnings (
	ticker TEXT NOT NULL,
	companyshortname TEXT NOT NULL,
	startdatetime TIMESTAMP NOT NULL,
	startdatetimetype TEXT NOT NULL,
	epsestimate DECIMAL NOT NULL,
	epsactual DECIMAL NOT NULL,
	epssurprisepct DECIMAL NOT NULL,
	timeZoneShortName TEXT NOT NULL,
	gmtOffsetMilliSeconds INTEGER NOT NULL,
	quoteType TEXT NOT NULL
);

CREATE INDEX earnings_ticker_idx ON earnings (ticker DESC);
