#!/bin/bash

export CHART_REPO=$1
export BASE=$2
export HEAD=$3
export GITHUB_TOKEN=$4

## Ensure that we pick the right regex for filtering gh pr list output based on HEAD
## If HEAD has a ":", then we want to grab the whole OWNER:BRANCH string
## Otherwise, just grab BRANCH
if [[ $HEAD == *":"* ]]; then
  regex=$HEAD
else
  regex='(?<!:)'"$HEAD"
fi

gh pr list --state open --base $BASE --repo $CHART_REPO | grep -P $regex
exit_code=$?
set -e
if [ $exit_code -eq 0 ]; then
  echo "FAIL: PR found, but no PR was expected"
  exit 1
else
  echo "PASS: No PR found"
  exit 0
fi