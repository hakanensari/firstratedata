#!/usr/bin/env python3

import csv
import datetime
import sys
import time
import traceback

from workalendar.usa import UnitedStates
from yahoo_earnings_calendar import YahooEarningsCalendar

from_date = datetime.date.fromisoformat(sys.argv[1])
to_date = datetime.date.today()
yec = YahooEarningsCalendar()
cal = UnitedStates()

earnings = []
current_date = from_date
delta = datetime.timedelta(days=1)
errors = 0

while current_date <= to_date:
    try:
        if cal.is_working_day(current_date):
            earnings += yec.earnings_on(current_date)
        current_date += delta
        errors = 0
        print(current_date)
    except KeyError as e:
        errors += 1
        if errors > 9:
            break

        backoff_time = 2**errors - 1
        time.sleep(backoff_time)
        pass

filename = ("earnings_%s.csv" % to_date)

with open(filename, 'w') as file:
    fieldnames = earnings[0].keys()
    writer = csv.DictWriter(file, fieldnames=fieldnames)

    writer.writeheader()
    for row in earnings:
        writer.writerow(row)
