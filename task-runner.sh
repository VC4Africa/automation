#!/bin/sh
# Make deployments.

# Let the world know what script we are executing.
echo "Start execution VC4Africa/automation/task-runner.sh..."
echo "Current path = $PWD"

# always good to know where are we and who are we!
whoami

REPOSITORY_URL=$1

# stripping https://github.com/
REPOSITORY_NAME=${REPOSITORY_URL:19}
CURRENT_BRANCH=$2
TEST_BRANCH=$CURRENT_BRANCH
GULP_COMMANDS=""
if [ $CURRENT_BRANCH != "staging" ] && [ $CURRENT_BRANCH != "master" ] && [ $CURRENT_BRANCH != "production" ]
then

 if [ -z "$3" ]
   then
     echo "Target branch argument is not supplied. Target branch set as master.";
     TEST_BRANCH="master";
 else
     echo "Target branch: $3";
     TEST_BRANCH=$3
     if [ $TARGET_BRANCH == "master" ]
     then
     TEST_BRANCH="staging"
     GULP_COMMANDS="gulp build_dev"
     fi
     if [ $TARGET_BRANCH == "production" ]
     then
     TEST_BRANCH="master"
     GULP_COMMANDS="gulp build"
     fi
 fi

fi


COMPOSER_COMMANDS=""
NPM_COMMANDS="yarn install"
case $REPOSITORY_NAME in
vc4a-dev/vc4a-theme.git)
  sudo rm -rf node_modules

  #if [ $TARGET_BRANCH != "production" ]
  #then
   # As a styles dependency, the styles theme needs to be available to prevent errors.
   sudo rm -rf styles
   git clone -b $TEST_BRANCH git@github.com:vc4a-dev/vc4a-styles.git styles

   # Correct paths from ../../../{../../}styles to being a subfolder in current path
   for i in $(find styles/. -iname "*.less"); do sed -i -e 's/\.\.\/\.\.\/\.\.\/\.\.\/\.\.\/\.\.\/styles/styles/g' $i; done
   for i in $(find styles/. -iname "*.less"); do sed -i -e 's/\.\.\/\.\.\/\.\.\/\.\.\/\.\.\/styles/styles/g' $i; done
   for i in $(find styles/. -iname "*.less"); do sed -i -e 's/\.\.\/\.\.\/\.\.\/\.\.\/styles/styles/g' $i; done
   for i in $(find styles/. -iname "*.less"); do sed -i -e 's/\.\.\/\.\.\/\.\.\/styles/styles/g' $i; done

   # As a community-styles dependency, the styles theme needs to be available to prevent errors.
   sudo rm -rf community
   git clone -b $TEST_BRANCH git@github.com:vc4a-dev/vc4a-community.git community

   # Correct paths for community theme less files.
   for i in $(find community/. -iname "*.less"); do sed -i -e 's/..\/..\/..\/..\/..\/..\/vc4africa/..\/..\/..\/..\/..\/../g' $i; done
   for i in $(find community/. -iname "*.less"); do sed -i -e 's/..\/..\/..\/..\/..\/vc4africa/..\/..\/..\/..\/../g' $i; done
   for i in $(find community/. -iname "*.less"); do sed -i -e 's/..\/..\/..\/..\/vc4africa/..\/..\/..\/../g' $i; done
   for i in $(find community/. -iname "*.less"); do sed -i -e 's/..\/..\/..\/vc4africa/..\/..\/../g' $i; done

   # Correct paths from ../../../community to being a subfolder in current path
   #sed -i -e 's/\.\.\/\.\.\/\.\.\/vc4africa/vc4africa/g' resources/less/style.less
   for i in $(find . -iname "*.less"); do sed -i -e 's/\.\.\/\.\.\/\.\.\/community/community/g' $i; done

  #fi

  ;;
vc4a-dev/vc4a-academy.git)
  sudo rm -rf node_modules

  # As a child theme, the parent theme needs to be available to prevent errors.
  sudo rm -rf vc4africa
  git clone -b $TEST_BRANCH git@github.com:vc4a-dev/vc4a-theme.git vc4africa

  # As a styles dependency, the styles theme needs to be available to prevent errors.
  sudo rm -rf styles
  git clone -b $TEST_BRANCH git@github.com:vc4a-dev/vc4a-styles.git styles

  # Correct paths from ../../../vc4africa to being a subfolder in current path
  #sed -i -e 's/\.\.\/\.\.\/\.\.\/vc4africa/vc4africa/g' resources/less/style.less
  for i in $(find . -iname "*.less"); do sed -i -e 's/\.\.\/\.\.\/\.\.\/\.\.\/\.\.\/\.\.\/vc4africa/vc4africa/g' $i; done
  for i in $(find . -iname "*.less"); do sed -i -e 's/\.\.\/\.\.\/\.\.\/\.\.\/\.\.\/vc4africa/vc4africa/g' $i; done
  for i in $(find . -iname "*.less"); do sed -i -e 's/\.\.\/\.\.\/\.\.\/\.\.\/vc4africa/vc4africa/g' $i; done
  for i in $(find . -iname "*.less"); do sed -i -e 's/\.\.\/\.\.\/\.\.\/vc4africa/vc4africa/g' $i; done

  ;;
vc4a-dev/vc4a-community.git)
  sudo rm -rf node_modules

  # As a child theme, the parent theme needs to be available to prevent errors.
  sudo rm -rf vc4africa
  git clone -b $TEST_BRANCH git@github.com:vc4a-dev/vc4a-theme.git vc4africa

  # As a styles dependency, the styles theme needs to be available to prevent errors.
  sudo rm -rf styles
  git clone -b $TEST_BRANCH git@github.com:vc4a-dev/vc4a-styles.git styles

  #sed -i -e 's/\.\.\/\.\.\/\.\.\/vc4africa/vc4africa/g' resources/less/style.less
  for i in $(find . -iname "*.less"); do sed -i -e 's/\.\.\/\.\.\/\.\.\/\.\.\/\.\.\/\.\.\/vc4africa/vc4africa/g' $i; done
  for i in $(find . -iname "*.less"); do sed -i -e 's/\.\.\/\.\.\/\.\.\/\.\.\/\.\.\/vc4africa/vc4africa/g' $i; done
  for i in $(find . -iname "*.less"); do sed -i -e 's/\.\.\/\.\.\/\.\.\/\.\.\/vc4africa/vc4africa/g' $i; done
  for i in $(find . -iname "*.less"); do sed -i -e 's/\.\.\/\.\.\/\.\.\/vc4africa/vc4africa/g' $i; done

  ;;
vc4a-dev/vc4a-mentors.git)
    sudo rm -rf node_modules

    # As a child theme, the parent theme needs to be available to prevent errors.
    sudo rm -rf vc4africa
    git clone -b $TEST_BRANCH git@github.com:vc4a-dev/vc4a-theme.git vc4africa

    # As a styles dependency, the styles theme needs to be available to prevent errors.
    sudo rm -rf styles
    git clone -b $TEST_BRANCH git@github.com:vc4a-dev/vc4a-styles.git styles

    #sed -i -e 's/\.\.\/\.\.\/\.\.\/vc4africa/vc4africa/g' resources/less/style.less
    for i in $(find . -iname "*.less"); do sed -i -e 's/\.\.\/\.\.\/\.\.\/\.\.\/\.\.\/\.\.\/vc4africa/vc4africa/g' $i; done
    for i in $(find . -iname "*.less"); do sed -i -e 's/\.\.\/\.\.\/\.\.\/\.\.\/\.\.\/vc4africa/vc4africa/g' $i; done
    for i in $(find . -iname "*.less"); do sed -i -e 's/\.\.\/\.\.\/\.\.\/\.\.\/vc4africa/vc4africa/g' $i; done
    for i in $(find . -iname "*.less"); do sed -i -e 's/\.\.\/\.\.\/\.\.\/vc4africa/vc4africa/g' $i; done

    ;;
vc4a-dev/vc4a-dashboard.git)
  sudo rm -rf node_modules

  # As a styles dependency, the styles theme needs to be available to prevent errors.
  sudo rm -rf styles
  git clone -b $TEST_BRANCH git@github.com:vc4a-dev/vc4a-styles.git styles
  cd styles && yarn install && gulp build && cd ..

  ;;
vc4a-dev/vc4a-styles.git)
  sudo rm -rf node_modules

  ;;
vc4a-dev/vc4a-consulting.git)
  echo "no commands available for vc4a-service-theme"
  ;;
vc4a-dev/mu-plugins.git)
  echo "no commands available for mu-plugins"
  ;;
vc4a-dev/vc4a-plugins.git)
  echo "no commands available for vc4a-service-theme"
  ;;
esac


echo "Executing task runner commands"
if [ -n "$NPM_COMMANDS" ];
then
echo "source ~/.bashrc"
source ~/.bashrc
echo "which node"
which node
echo "which npm"
which npm
# Install yarn if it's not available.
yarn --version || ( echo 'Yarn does not exists installing yarn...' && npm install -g yarn )
echo "which yarn"
which yarn
echo "node --version"
node --version
echo "npm --version"
npm --version
echo "yarn --version"
yarn --version
echo "sudo node --version"
sudo node --version
echo "sudo npm --version"
sudo npm --version

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
echo $COMPOSER_COMMANDS;
$COMPOSER_COMMANDS || $COMPOSER_COMMANDS || $COMPOSER_COMMANDS || exit 1
exitcode=$?
    if [ $exitcode != 0 ];
        then
        echo "$COMPOSER_COMMANDS failed"
        exit $exitcode;
    fi
fi

# remove sed replacements
git checkout -f . || git checkout -f . || ( echo 'git checkout failed' && exit 1 )
echo "Task runner commands are succeeded."
