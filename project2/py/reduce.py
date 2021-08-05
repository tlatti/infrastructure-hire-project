# https://www.accelebrate.com/blog/using-defaultdict-python

import json
from collections import defaultdict
import boto3

s3 = boto3.client('s3')
s3.download_file('tl-incidents2', 'example.json', 'example.json')

with open('example.json') as f:
  data = json.load(f)

vulncalc = defaultdict(lambda: { "HIGH":0, "MEDIUM":0, "LOW":0 })
for vendor in data['vulnerabilities']:
    vulncalc[vendor['vendor_id']][vendor['severity']] += 1

with open('results.json', 'w') as f:
  json.dump(vulncalc, f)
  f.write('\n')
