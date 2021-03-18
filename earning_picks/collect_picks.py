#!/usr/bin/env python3

import csv
import datetime
import os
import re
import sys

path = sys.argv[1]

csvfile = open('earning_picks.csv', 'w')
fieldnames = ['date', 'symbol']

writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
writer.writeheader()

for entry in os.scandir(path):
    m = re.search(r'(\d{4})', entry.name)
    year = m.group(1)

    for entry in os.scandir(entry.path):
        m = re.search(r'\.([A-Z][a-z]+)(\d+)', entry.name)

        if m is None:
            continue

        month = m.group(1)
        day = m.group(2)
        if month == 'Jun':
            month = 'June'

        date = datetime.datetime.strptime(f'{year} {month} {day.zfill(2)}', "%Y %B %d").date()

        csvfile = open(f'{entry.path}/tiny(70000).csv')
        reader = csv.reader(csvfile)

        for row in reader:
            if len(row) == 0:
                continue

            symbol = row[0]
            if re.match(r'^[A-Z]+$', symbol) and symbol != 'DEFAULT':
                writer.writerow({'date': date, 'symbol': symbol})
