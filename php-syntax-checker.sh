#!/bin/sh
# Check php syntax

# always good to know where are we and who are we!
echo "Who am I ?"
whoami
echo "Where am I ?"
pwd

GIT_PREVIOUS_COMMIT=$1
GIT_COMMIT=$2
REPOSITORY_URL=$3
# stripping https://github.com/
REPOSITORY_NAME=${REPOSITORY_URL:19}

git remote set-url origin git@github.com:${REPOSITORY_NAME}
git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
echo "Fetching all"
git fetch --all

echo "changed files"
git diff --diff-filter=ACMR --name-only $GIT_PREVIOUS_COMMIT $GIT_COMMIT

# show different php files only
echo "changed php files"
git diff --diff-filter=ACMR --name-only $GIT_PREVIOUS_COMMIT $GIT_COMMIT | grep .php$

( ( (git diff --diff-filter=ACMR --name-only $GIT_PREVIOUS_COMMIT $GIT_COMMIT ) | grep .php$ ) | xargs -n1 echo php -l | bash ) | grep -v "No syntax errors detected" && echo "PHP Syntax error(s) detected" && exit 1;