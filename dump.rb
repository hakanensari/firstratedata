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
  dataset = pg[:earning_picks].where{date > '2019-01-01'}
  picks = dataset.reduce({}) do |memo, pick|
    date = strategy == 'earnings' ? pick[:date].iso8601 : (pick[:date] + 1).iso8601
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
      Integer :printsize, null: false
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
        printsize: record[:print_size],
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
VARS,indicators.csv
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
