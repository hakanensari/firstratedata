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
  days = dataset.reduce({}) do |memo, pick|
    date = strategy == 'earnings' ? pick[:date].iso8601 : (pick[:date] + 1).iso8601
    (memo[date] ||= []) << pick[:symbol]
    memo
  end

  # Metadata
  sqlite.create_table :atrader_metadata do
    String :name, null: false
    Float :info, null: false
  end
  data = days.map { |date, _| { name: "test_#{date.tr('-', '')}", info: 1.2 } }
  sqlite[:atrader_metadata].multi_insert(data)

  days.each do |date, symbols|
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
    sqlite["test_#{date.tr('-', '')}".to_sym].multi_insert(data)

    # Indicators
    FileUtils.mkdir_p "backtest/#{strategy}/test_#{date.tr('-', '')}"
    sql = sql_template_for_indicators
        .gsub('{{symbol}}', "symbol=any('{#{symbols.join(',')}}')")
        .gsub('{{datetime}}', "'#{date}'")
    data = pg.fetch(sql)
    CSV.open("backtest/#{strategy}/test_#{date.tr('-', '')}/indicators.csv", 'wb', write_headers: true, headers: data.first.keys) do |csv|
      data.each do |record|
        csv << record.values
      end
    end
  end
end
