#!/bin/bash

set -e

export UPSTREAM_REPO=$1
export HEAD=$2
export GITHUB_TOKEN=$3

gh pr list --state open --repo $UPSTREAM_REPO | grep $HEAD | while read line; do
  pr_number=$(echo $line | awk '{print $1}')
  gh pr close $pr_number --repo $UPSTREAM_REPO
done