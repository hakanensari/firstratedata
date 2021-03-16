#!/usr/bin/env python3

import csv
import datetime
import sys
import time
import traceback

from workalendar.usa import UnitedStates
from yahoo_earnings_calendar import YahooEarningsCalendar

yec = YahooEarningsCalendar()
cal = UnitedStates()

from_date = datetime.date.fromisoformat(sys.argv[1])
to_date = datetime.date.fromisoformat(sys.argv[2]) if len(sys.argv) == 3 else datetime.date.today()
current_date = from_date
delta = datetime.timedelta(days=1)
earnings = []
errors = 0

while current_date <= to_date:
    try:
        if cal.is_working_day(current_date):
            earnings += yec.earnings_on(current_date)

        print(current_date)
        current_date += delta
        errors = 0
    except KeyError as e:
        if errors > 7:
            traceback.print_exc()
            break

        errors += 1
        backoff_time = 2**errors - 1
        time.sleep(backoff_time)
        pass
    except Exception as e:
        traceback.print_exc()
        break

filename = f'earnings_{from_date}_{current_date}.csv'

with open(filename, 'w') as file:
    fieldnames = earnings[0].keys()
    writer = csv.DictWriter(file, fieldnames=fieldnames)

    writer.writeheader()
    for row in earnings:
        writer.writerow(row)
