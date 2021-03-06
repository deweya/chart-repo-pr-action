#!/bin/bash

set -e

export CHART_REPO=$1
export BASE=$2
export HEAD=$3
export GITHUB_TOKEN=$4
export DIFF_FILE=$5

## Ensure that we pick the right regex for filtering gh pr list output based on HEAD
## If HEAD has a ":", then we want to grab the whole OWNER:BRANCH string
## Otherwise, just grab BRANCH
if [[ $HEAD == *":"* ]]; then
  regex=$HEAD
else
  regex='(?<!:)'"$HEAD"
fi

pr_number=$(gh pr list --state open --base $BASE --repo $CHART_REPO | grep -P $regex | awk '{print $1}')
gh pr diff $pr_number --repo $CHART_REPO > pr-diff.txt

set +e

diff pr-diff.txt test/$5
exit_code=$?
set -e
if [ $exit_code -eq 0 ]; then
  echo "PASS: PR diff contains the expected contents"
  exit 0
else
  echo "FAIL: PR diff does not contain the expected contents"
  exit 1
fi