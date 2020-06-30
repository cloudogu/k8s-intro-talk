#!/usr/bin/env bash
BASEDIR=$(dirname $0)

sed -n -e '/```bash/,/```/ p' ${BASEDIR}/03-k8s.md | sed '/```bash/d; s/```/\n---\n/' | tee listings.txt
