#!/bin/bash

set -e

export BASE=$1
export UPSTREAM_REPO=$2
export HEAD=$3
export GITHUB_TOKEN=$4
export DIFF_FILE=$5

pr_number=$(gh pr list --state open --base $BASE --repo $UPSTREAM_REPO | grep $HEAD | awk '{print $1}')
gh pr diff $pr_number --repo $UPSTREAM_REPO > pr-diff.txt

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