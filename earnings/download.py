#!/usr/bin/env python3

import csv
import datetime
from yahoo_earnings_calendar import YahooEarningsCalendar

date_from = datetime.date(2015, 1, 4)
date_to = datetime.date.today()
earnings = YahooEarningsCalendar().earnings_between(date_from, date_to)
filename = ("earnings-%s.csv" % date_to)
with open(filename, 'w') as file:
    fieldnames = earnings[0].keys()
    writer = csv.DictWriter(file, fieldnames=fieldnames)
    writer.writeheader()
    for row in earnings:
        writer.writerow(row)
