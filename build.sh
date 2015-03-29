#!/bin/bash

# only proceed script when started not by pull request (PR)
if [ $TRAVIS_PULL_REQUEST == "true" ]; then
  echo "this is PR, exiting"
  exit 0
fi

# enable error reporting to the console
set -e

# build site with jekyll, by default to `_site' folder
jekyll build

# cleanup
rm -rf ../${GH_REPO}.${GH_PAGES_BRANCH}

#clone `${GH_BRANCH}' branch of the repository using encrypted GH_TOKEN for authentification
git clone -b ${GH_BRANCH} https://${GH_TOKEN}@github.com/${GH_USER}/${GH_REPO}.git ../${GH_REPO}.${GH_BRANCH}

# copy generated HTML site to `${GH_BRANCH}' branch
cp -R _site/* ../${GH_REPO}.${GH_BRANCH}

# commit and push generated content to `${GH_BRANCH}' branch
# since repository was cloned in write mode with token auth - we can push there
cd ../${GH_REPO}.${GH_BRANCH}
git config user.email "${GH_GIT_EMAIL}"
git config user.name "${GH_GIT_NAME}"
git add -A .
git commit -a -m "Travis #$TRAVIS_BUILD_NUMBER"
git push --quiet origin ${GH_BRANCH} > /dev/null 2>&1 
