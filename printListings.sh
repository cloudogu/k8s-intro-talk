#!/usr/bin/env bash
BASEDIR=$(dirname $0)

rm listings.txt

for file in ${BASEDIR}/docs/slides/*.md; do
    sed -n -e '/```bash/,/```/ p' "${file}" | sed '/```bash/d; s/```/\n---\n/' | tee -a listings.txt
done
