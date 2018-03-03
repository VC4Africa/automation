#!/bin/sh
# Check php syntax for changed files with latest commits only.

# always good to know where are we and who are we!
echo "Who am I ?"
whoami
echo "Where am I ?"
pwd

GIT_PREVIOUS_COMMIT=$1
GIT_COMMIT=$2
REPOSITORY_URL=$3
if [ $GIT_PREVIOUS_COMMIT = $GIT_COMMIT ]
then
  # let's assume going back to 30 commits would be enough for covering even an exceptional huge PR case.
  GIT_PREVIOUS_COMMIT=$(git rev-list -30 --skip=29 --max-count=1 HEAD)
fi
# stripping https://github.com/
REPOSITORY_NAME=${REPOSITORY_URL:19}
sudo git config --unset-all remote.origin.fetch
sudo git remote set-url origin git@github.com:${REPOSITORY_NAME}
sudo git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
echo "track all"
sudo git branch -r | grep -v '\->' | while read remote; do sudo git branch --track "${remote#origin/}" "$remote"; done

echo "Fetching all"
sudo git fetch --all

echo "all changed files"
sudo git diff --diff-filter=ACMR --name-only $GIT_PREVIOUS_COMMIT $GIT_COMMIT

# show different php files only
echo "changed php files"
sudo git diff --diff-filter=ACMR --name-only $GIT_PREVIOUS_COMMIT $GIT_COMMIT | grep .php$

( ( sudo git diff --diff-filter=ACMR --name-only $GIT_PREVIOUS_COMMIT  $GIT_COMMIT | grep .php$ ) | xargs -n1 echo php -l | bash ) |  (grep -v "No syntax errors detected" ) && echo "PHP Syntax error(s) detected" && exit 1

exitcode=$?
if [ $exitcode != 0 ];
    then
    echo "syntax errors detected"
    exit $exitcode;
fi

echo "no syntax errors detected" && exit 0