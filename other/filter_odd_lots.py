#!/usr/bin/env python3

import csv

input_file = open('prints.csv')
output_file = open('prints.filtered.csv', 'w')

output_file.write(next(input_file))
output_file.write(next(input_file))

reader = csv.reader(input_file)
for row in reader:
    print_size = int(row[7])
    if print_size >= 100:
        output_file.write(','.join(row) + "\n")
