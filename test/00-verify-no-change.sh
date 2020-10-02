#!/bin/bash

export BASE=$1
export UPSTREAM_REPO=$2
export HEAD=$3
export GITHUB_TOKEN=$4

gh pr list --state open --base $BASE --repo $UPSTREAM_REPO | grep $HEAD
exit_code=$?
set -e
if [ $exit_code -eq 0 ]; then
  echo "FAIL: PR found, but no PR was expected"
  exit 1
else
  echo "PASS: No PR found"
  exit 0
fi