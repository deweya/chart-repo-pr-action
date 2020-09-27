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

## Push to fork if there are changes to $LOCAL_CHARTS_DIR
## If there are not any changes to $LOCAL_CHARTS_DIR, the action will end here
cd charts-fork
git config user.name $COMMITTER_NAME
git config user.email $COMMITTER_EMAIL
git checkout $SOURCE_BRANCH || git checkout -b $SOURCE_BRANCH
cp -r ../$LOCAL_CHARTS_DIR/* $UPSTREAM_CHARTS_DIR/
git add --all
## If there are no changes, then exit. Else, commit and push to fork.
if git diff-index --quiet HEAD; then
  echo "INFO: no changes detected. Exiting..."
  exit 0
else
  git commit -m "$COMMIT_MESSAGE"
fi
git push origin $SOURCE_BRANCH

## Create PR
export GITHUB_USER=$COMMITTER_NAME
export GITHUB_TOKEN=$AUTH_TOKEN
## Determine if PR already exists
fork_owner=$(echo $FORK_NAME | cut -d '/' -f1)
fork_repo=$(echo $FORK_NAME | cut -d '/' -f2)
set +e
gh pr list --state open --base $TARGET_BRANCH --repo $UPSTREAM_OWNER/$fork_repo | grep $fork_owner:$SOURCE_BRANCH
exit_code=$?
set -e
if [ $exit_code -eq 0 ]; then
  echo "INFO: pr already exists. Exiting..."
  exit 0
else
  gh pr create --base $TARGET_BRANCH --head $fork_owner:$SOURCE_BRANCH --title "$COMMIT_MESSAGE" --body "Syncing charts from $FORK_NAME" --repo $UPSTREAM_OWNER/$fork_repo
fi