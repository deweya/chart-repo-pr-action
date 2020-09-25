#!/bin/sh

set -e

## Ensure charts/ directory exists
if [ ! -d "charts" ]; then
  echo "ERR: directory 'charts/' does not exist"
  exit 1
fi

## Clone fork
git clone https://deweya:$INPUT_TOKEN@github.com/deweya/helm-charts

## Push to fork
## TODO: The pipeline should not fail if no changes are pushed. It should just exit 0 here and not continue to create the PR
cd helm-charts
git config user.name $GITHUB_ACTOR
git config user.email deweya964@gmail.com
git checkout feat/sync || git checkout -b feat/sync
cp -r ../charts/* charts/
git add --all
git commit -m 'Syncing local charts with Helm chart repo'
git push origin feat/sync

## Create PR
export GITHUB_USER=$GITHUB_ACTOR
export GITHUB_TOKEN=$INPUT_TOKEN
hub pull-request -b deweya0:master -h feat/sync --no-edit