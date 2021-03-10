DROP TABLE IF EXISTS trades CASCADE;

CREATE TABLE trades (
	account TEXT NOT NULL,
	opened TIMESTAMP NOT NULL,
	closed TIME NOT NULL,
	held INTERVAL NOT NULL,
	symbol TEXT NOT NULL,
	"type" TEXT NOT NULL,
	entry DECIMAL NOT NULL,
	exit DECIMAL NOT NULL,
	qty INTEGER NOT NULL,
	gross DECIMAL NOT NULL,
	alloc_exp DECIMAL NOT NULL,
	ecn_fee DECIMAL NOT NULL,
	trans_fee DECIMAL NOT NULL,
	reg_free_occ DECIMAL NOT NULL,
	nscc DECIMAL NOT NULL,
	foreign_trans_fee DECIMAL,
	misc DECIMAL,
	net DECIMAL NOT NULL
);

CREATE INDEX trades_account_opened_idx ON trades (account, opened DESC);
