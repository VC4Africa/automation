#!/bin/sh
# Make deployments.

# always good to know where are we and who are we!
whoami
pwd

SCRIPT_NAME=$(basename "$0")
echo "script name ${SCRIPT_NAME}"
CURRENT_BRANCH=$1
REPOSITORY_URL=$2
# stripping https://github.com/
REPOSITORY_NAME=${REPOSITORY_URL:19}

case $CURRENT_BRANCH in
production)
  URL="clone.staging-vc4a.com"
  ;;
master)
  URL="master.staging-vc4a.com"
  ;;
staging)
  URL="staging-vc4a.com"
  ;;
esac

MAIN_PATH="/var/www/html/"${URL}

GULP_COMMANDS=""
NPM_COMMANDS=""
COMPOSER_COMMANDS=""

case $REPOSITORY_NAME in
billz/vc4a-theme.git)
  SUB_PATH=${MAIN_PATH}"/wp-content/themes/vc4africa"
  NPM_COMMANDS="yarn install"
  GULP_COMMANDS="gulp build"
  ;;
billz/theme-academy.git)
  SUB_PATH=${MAIN_PATH}"/wp-content/themes/academy"
  NPM_COMMANDS="yarn install"
  GULP_COMMANDS="gulp build"
  ;;
billz/theme-community.git)
  SUB_PATH=${MAIN_PATH}"/wp-content/themes/community"
  NPM_COMMANDS="yarn install"
  GULP_COMMANDS="build"
  ;;
billz/vc4a-dashboard.git)
  SUB_PATH=${MAIN_PATH}"/wp-content/themes/dashboard"
  NPM_COMMANDS="yarn install"
  GULP_COMMANDS="yarn run build"
  ;;
billz/vc4a-service-theme.git)
  SUB_PATH=${MAIN_PATH}"/wp-content/themes/consulting"
  ;;
vc4a-dev/vc4a-mentors.git)
  SUB_PATH=${MAIN_PATH}"/wp-content/themes/mentors"
  NPM_COMMANDS="yarn install"
  GULP_COMMANDS="gulp"
  ;;
billz/mu-plugins.git)
  SUB_PATH=${MAIN_PATH}"/wp-content/mu-plugins"
  COMPOSER_COMMANDS="sudo php composer.phar install --no-dev -n"
  ;;
billz/vc4a-plugins.git)
  SUB_PATH=${MAIN_PATH}"/wp-content/plugins"
  ;;
esac

if [ $SCRIPT_NAME != "deployer.sh" ];
then

    echo 'Entering to sub path'
    echo "cd $SUB_PATH"
    cd $SUB_PATH || exit 1
    exitcode=$?
    if [ $exitcode != 0 ];
        then
        echo "Entering to $SUB_PATH failed"
        exit $exitcode;
    fi

    echo "Reset ownership and git reset --hard origin/$CURRENT_BRANCH"
    sudo chown -R deploy:www-data .
    git reset --hard origin/$CURRENT_BRANCH
    echo "Pull from origin -> git pull origin $CURRENT_BRANCH "
    git pull origin $CURRENT_BRANCH
    echo "Checkout to branch"
    echo "git checkout -f ."
    git checkout -f . || sudo git checkout -f . || exit 1
    echo "git checkout -f $CURRENT_BRANCH"
    git checkout -f $CURRENT_BRANCH || sudo git checkout -f $CURRENT_BRANCH || exit 1
    exitcode=$?
    if [ $exitcode != 0 ];
        then
        echo "Checkout to branch failed"
        exit $exitcode;
    fi

    echo "Update the branch"
    echo "git pull"
    git pull || sudo chown -R deploy:www-data . && git pull || exit 1
    exitcode=$?
    if [ $exitcode != 0 ];
        then
        echo "Update the branch failed"
        exit $exitcode;
    fi

    echo "Executing task runner commands"
    if [ -n "$NPM_COMMANDS" ];
    then
    echo $NPM_COMMANDS;
    $NPM_COMMANDS || $NPM_COMMANDS || exit 1
    exitcode=$?
        if [ $exitcode != 0 ];
            then
            echo "$NPM_COMMANDS failed"
            exit $exitcode;
        fi
    fi

    if [ -n "$GULP_COMMANDS" ];
    then
    echo $GULP_COMMANDS;
    $GULP_COMMANDS || $GULP_COMMANDS || exit 1
    exitcode=$?
        if [ $exitcode != 0 ];
            then
            echo "$GULP_COMMANDS failed"
            exit $exitcode;
        fi
    fi

    if [ -n "$COMPOSER_COMMANDS" ];
    then
    sudo rm -f composer.phar
    sudo wget https://getcomposer.org/download/1.9.1/composer.phar
    echo $COMPOSER_COMMANDS;
    $COMPOSER_COMMANDS || $COMPOSER_COMMANDS || exit 1
    exitcode=$?
        if [ $exitcode != 0 ];
            then
            echo "$COMPOSER_COMMANDS failed"
            exit $exitcode;
        fi
    fi

    echo 'Set folder ownerships back to deploy:www-data'
    sudo chown -R deploy:www-data $MAIN_PATH || exit 1
    if [ $exitcode != 0 ];
        then
        echo "Set folder ownerships failed"
        exit $exitcode;
    fi
fi

if [ $SCRIPT_NAME = "deployer.sh" ];
then
    if [ -e dynamic_deploy.sh ]; then
      sudo rm -f dynamic_deploy.sh
    fi

    sudo cp -avr deployer.sh dynamic_deploy.sh
fi

if [ $SCRIPT_NAME = "deployer.sh" ];
then
( ssh deploy@${URL} 'bash -s' < dynamic_deploy.sh ${CURRENT_BRANCH} ${REPOSITORY_URL} ) || ( echo 'deployment is failed' && exit 1 )
fi
