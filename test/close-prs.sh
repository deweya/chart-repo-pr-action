#!/bin/bash

set -e

## BASE is not included here because we want to delete all PRs from HEAD, regardless of BASE
## This makes it easier to test multiple BASEs.
export CHART_REPO=$1
export HEAD=$2
export GITHUB_TOKEN=$3

gh pr list --state open --repo $CHART_REPO | grep -P $HEAD | while read line; do
  pr_number=$(echo $line | awk '{print $1}')
  gh pr close $pr_number --repo $CHART_REPO
done