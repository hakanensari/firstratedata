#!/usr/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'fileutils'
require 'pry'
require 'sequel'

sql_template_for_ticks = File.read('sql/export_all_to_atrader.sql')
sql_template_for_indicators = File.read('sql/export_indicators_to_atrader.sql')

%w[earnings earnings_2nd_day].each do |strategy|
  FileUtils.mkdir_p 'backtest'
  FileUtils.rm_rf "backtest/#{strategy}"
  FileUtils.mkdir "backtest/#{strategy}"
  sqlite = Sequel.sqlite("backtest/#{strategy}/data.sqlite")
  pg = Sequel.connect(ARGV[0])

  # Picks
  #
  # We exclude stocks who have no ticks or just one tick in the first minute. The latter implies a stock may still be
  # trading pre-market, which we cannot figure out from bar data.
  pg.extension :date_arithmetic
    dataset = pg[:picks]
      .with(:picks,
            pg[:earning_picks]
              .select(:symbol,
                      :date,
                      pg[:stocks_1m]
                        .select(Sequel.as(Sequel.lit('high - low'), :highlowdiff))
                        .where{{symbol: earning_picks[:symbol],
                                datetime: Sequel.date_add(earning_picks[:date], hours: 9, minutes: 30)}}
                        .limit(1))
              .where{date > '2019-01-01'},
            materialized: true)
      .select(:date, :symbol)
      .where{highlowdiff > 0}
      .exclude(highlowdiff: nil)
      .all

  # Build a smaller sample
  if ARGV[1] == 's'
    # Slovin's formula
    population_size = dataset.count
    sample_size = (population_size / (1 + population_size * 0.05 ** 2)).round
    dataset = dataset.sample(sample_size)
  end

  cached_date_conversions = {}
  picks = dataset.reduce({}) do |memo, pick|
    date =
      if strategy == 'earnings'
        date = pick[:date].iso8601
      else
        if cached_date_conversions.key?(pick[:date].iso8601)
          cached_date_conversions[pick[:date].iso8601]
        else
          cached_date_conversions[pick[:date].iso8601] =
            pg[:stocks_1m]
              .where{datetime>=pick[:date] + 1}
              .order(:datetime)
              .limit(1)
              .select_map(:datetime)
              .first.to_date.iso8601
        end
      end
    (memo[date] ||= []) << pick[:symbol]
    memo
  end
  dates_picked = []

  picks.each do |date, symbols|
    # Ticks
    sqlite.create_table "test_#{date.tr('-', '')}" do
      Integer :printtime, null: false
      String :symbol, null: false
      Float :last, null: false
      String :primary_exchange, null: false
      String :exec_exchange, null: false
      Float :xopen, null: false
      Float :bid, null: false
      Float :ask, null: false
      Float :pclose, null: false
      Integer :print_size, null: false
      String :sale_condition, null: false
    end
    sql = sql_template_for_ticks
      .gsub('{{symbol}}', "symbol=any('{#{symbols.join(',')}}')")
      .gsub('{{datetime}}', "'#{date}'")
    data = pg.fetch(sql).map do |record|
      {
        printtime: record[:printtime],
        symbol: record[:name],
        last: record[:last],
        primary_exchange: record[:primary_exchange_name],
        exec_exchange: record[:exec_exchange_name],
        xopen: record[:xopen],
        bid: record[:bid],
        ask: record[:bid],
        pclose: record[:bid],
        print_size: record[:print_size],
        sale_condition: record[:sale_conditions]
      }
    end
    if data.empty?
      puts "#{strategy}/#{date} has no data"
      next
    end
    sqlite["test_#{date.tr('-', '')}".to_sym].multi_insert(data)

    # Indicators
    FileUtils.mkdir_p "backtest/#{strategy}/test_#{date.tr('-', '')}"
    sql = sql_template_for_indicators
        .gsub('{{symbol}}', "symbol=any('{#{symbols.join(',')}}')")
        .gsub('{{datetime}}', "'#{date}'")
    data = pg.fetch(sql)
    CSV.open("backtest/#{strategy}/test_#{date.tr('-', '')}/indicators.csv", 'wb', write_headers: true, headers: data.first.keys) do |csv|
      data.each do |record|
        csv << record.values.map { |val| val.is_a?(BigDecimal) ? val.to_f : val }
      end
    end

    dates_picked << date
  end

  # Metadata
  sqlite.create_table :atrader_metadata do
    String :name, null: false
    Float :info, null: false
  end
  data = dates_picked.map { |date| { name: "test_#{date.tr('-', '')}", info: 1.2 } }
  sqlite[:atrader_metadata].multi_insert(data)

  # Config file
  file = File.open("backtest/#{strategy}/config.csv", 'w')
  file.write <<-EOF
TESTSUIT
THREADSLIMIT,12
MARKETFILE,data.sqlite
OUTPATH,logs
#SKIPSCRIPTLOGS
#MARKETFILTER,marketfilter.csv
#MARKETFILTERVARS,marketfiltervars.csv
VARS,indicators.csv
#ORDERSIZE,ordersize.csv
#RANGES,ranges.csv
LOG_VARS,${counter},${prevclose},${prevhi},${prevlow},${avervolume},${Datr},${yatr},${fMav55},${fMa233},${oMav55},${Today},${startatrratio},${entryatrratio},${dayatrratio},${entrytimefromxopen},${entrytimefromhighlow},${entrylegtime},${entryside},${barcolor},${alternativeentry1},${buytrigger},${selltrigger}
SAVEMARKETFILTERLOGS,true

EOF

  dates_picked.sort.each do |date|
    file.write <<-EOF
TESTCASE
MARKETDATASOURCE,#{"test_#{date.tr('-', '')}"}
SEARCHPATH,#{"test_#{date.tr('-', '')}"}
MARKETFILE,-
MARKETFILTER,-
VARS,-
ORDERSIZE,-
RANGES,-
STRATEGY,STRATEGY_NAME_HERE.csv

EOF
  end
end
