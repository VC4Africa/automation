#!/bin/sh
# Check js syntax for changed files with latest commits only.
GIT_PREVIOUS_COMMIT=$1
GIT_COMMIT=$2
REPOSITORY_URL=$3

# always good to know where are we and who are we!
echo "Who am I?"
whoami
echo "Where am I?"
pwd
echo "Git username?"
git git config user.name

echo "Repository: $REPOSITORY_URL"

if [ $GIT_PREVIOUS_COMMIT = $GIT_COMMIT ] || [ $GIT_PREVIOUS_COMMIT = "" ]; then
  # let's assume going back to 30 commits would be enough for covering even an exceptional huge PR case.
  GIT_PREVIOUS_COMMIT=$(git rev-list -30 --skip=29 --max-count=1 HEAD)
fi

echo "Set ownership to deploy"
sudo chown deploy:www-data . -R

# Stripping https://github.com/
REPOSITORY_NAME=${REPOSITORY_URL:19}
echo "Repository name = $REPOSITORY_NAME"
git config --unset-all remote.origin.fetch
echo "Set origin = git@github.com:$REPOSITORY_NAME"
git remote set-url origin git@github.com:${REPOSITORY_NAME}
git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
echo "track all"
git branch -r | grep -v '\->' | while read remote; do git branch --track "${remote#origin/}" "$remote"; done

echo "Git Fetch --all"
git fetch --all

echo "All changed files"
git diff --diff-filter=ACMR --name-only $GIT_PREVIOUS_COMMIT $GIT_COMMIT

# show different js files only
changedjs=$(git diff --diff-filter=ACMR --name-only $GIT_PREVIOUS_COMMIT $GIT_COMMIT | grep .js$ | grep -v wpml-translation-management/ | grep -v node_modules/ | grep -v vendor/ | grep -v gulpfile.babel.js)

# only run esvalidate where there are changes
if [[ -n $changedjs ]]; then
  echo "Checking syntax of modified js files.."
  echo "Using eslint -v"
  eslint -v || sudo npm install -g eslint
  
  git diff --diff-filter=ACMR --name-only $GIT_PREVIOUS_COMMIT $GIT_COMMIT | grep .js$ | grep -v wpml-translation-management/ | grep -v node_modules/ | grep -v vendor/ | grep -v gulpfile.babel.js | xargs -n1 echo eslint --no-eslintrc --env es6 --parser-options=ecmaVersion:8 | bash 
else
  echo "No JS modifications found, skipping syntax checks."
fi

echo "no js syntax errors detected" && exit 0
