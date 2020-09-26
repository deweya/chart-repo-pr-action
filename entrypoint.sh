#!/bin/sh

set -e

export AUTH_TOKEN=$INPUT_AUTH_TOKEN
export AUTH_USER=${INPUT_AUTH_USER:-$GITHUB_ACTOR}
export LOCAL_CHARTS_DIR=$INPUT_LOCAL_CHARTS_DIR
export UPSTREAM_CHARTS_DIR=$INPUT_UPSTREAM_CHARTS_DIR
export FORK_NAME=$INPUT_FORK_NAME
export UPSTREAM_OWNER=$INPUT_UPSTREAM_OWNER
export COMMITTER_NAME=${INPUT_COMMITTER_NAME:-$GITHUB_ACTOR}
export COMMITTER_EMAIL=$INPUT_COMMITTER_EMAIL
export COMMIT_MESSAGE=$INPUT_COMMIT_MESSAGE
export SOURCE_BRANCH=$INPUT_SOURCE_BRANCH
export TARGET_BRANCH=$INPUT_TARGET_BRANCH

## Ensure LOCAL_CHARTS_DIR directory exists in local repo
if [ ! -d "$LOCAL_CHARTS_DIR" ]; then
  echo "ERR: directory '$LOCAL_CHARTS_DIR' does not exist"
  exit 1
fi

## Clone fork
git clone https://$AUTH_USER:$AUTH_TOKEN@github.com/$FORK_NAME charts-fork

## Push to fork
## TODO: The pipeline should not fail if no changes are pushed. It should just exit 0 here and not continue to create the PR
cd charts-fork
git config user.name $COMMITTER_NAME
git config user.email $COMMITTER_EMAIL
git checkout $SOURCE_BRANCH || git checkout -b $SOURCE_BRANCH
cp -r ../$LOCAL_CHARTS_DIR/* $UPSTREAM_CHARTS_DIR/
git add --all
git commit -m "$COMMIT_MESSAGE"
git push origin $SOURCE_BRANCH

## Create PR
## GITHUB_USER is required for "hub"
export GITHUB_USER=$COMMITTER_NAME
export GITHUB_TOKEN=$AUTH_TOKEN
hub pull-request -b $UPSTREAM_OWNER:$TARGET_BRANCH -h $SOURCE_BRANCH --no-edit