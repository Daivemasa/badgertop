#!/bin/bash
# Kolikrát se Badgertop stáhl z GitHubu (všechna vydání, DMG + ZIP).
curl -s "https://api.github.com/repos/Daivemasa/badgertop/releases?per_page=100" | python3 -c '
import sys, json
total = 0
for r in json.load(sys.stdin):
    for a in r.get("assets", []):
        n = a["download_count"]; total += n
        print("%8s  %-24s %6d" % (r["tag_name"], a["name"], n))
print("%8s  %-24s %6d" % ("celkem", "", total))
'
