#!/bin/sh

set -e

## Ensure charts/ directory exists
if [ ! -d "charts" ]; then
  echo "ERR: directory 'charts/' does not exist"
  exit 1
fi

## Clone fork and move local charts over
git clone https://deweya:$INPUT_TOKEN@github.com/deweya/helm-charts
mv charts/* helm-charts/charts/
ls -l helm-charts/charts/

## Push to fork
cd helm-charts
git config user.name $GITHUB_ACTOR
git config user.email deweya964@gmail.com
git add --all
git commit -m 'test'
git push origin master