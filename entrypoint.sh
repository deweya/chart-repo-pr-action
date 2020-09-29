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
cd ../
git clone https://$AUTH_USER:$AUTH_TOKEN@github.com/$FORK_NAME charts-fork
cd charts-fork
git config user.name $COMMITTER_NAME
git config user.email $COMMITTER_EMAIL

## Update local master to upstream
fork_owner=$(echo $FORK_NAME | cut -d '/' -f1)
fork_repo=$(echo $FORK_NAME | cut -d '/' -f2)
git remote add upstream https://github.com/$UPSTREAM_OWNER/$fork_repo
git checkout $TARGET_BRANCH
git pull upstream $TARGET_BRANCH

## Push to fork if there are changes to $LOCAL_CHARTS_DIR
## If there are not any changes to $LOCAL_CHARTS_DIR, the action will end here
git checkout $SOURCE_BRANCH || git checkout -b $SOURCE_BRANCH
git reset --hard $TARGET_BRANCH

cd $GITHUB_WORKSPACE/$LOCAL_CHARTS_DIR
for chart in */; do
  rm -rfv ../../charts-fork/$UPSTREAM_CHARTS_DIR/$chart
  cp -rv $chart ../../charts-fork/$UPSTREAM_CHARTS_DIR/
done

cd ../../charts-fork
git status
git add --all
exit_early=true
if ! git diff-index --quiet HEAD; then
  git commit -m "$COMMIT_MESSAGE"
  exit_early=false
fi
git push origin $SOURCE_BRANCH --force
if [ "$exit_early" = true ]; then
  echo "INFO: no change detected against target branch. Exiting early..."
  exit 0
fi

## Create PR
export GITHUB_USER=$COMMITTER_NAME
export GITHUB_TOKEN=$AUTH_TOKEN
## Determine if PR already exists
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