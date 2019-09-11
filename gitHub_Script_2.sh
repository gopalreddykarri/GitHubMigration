#!/usr/bin/env bash

set -e -x

repoNameFilePath=`pwd`

rm -rf ~/gkarri/githubMigration
mkdir -p ~/gkarri/githubMigration
cd ~/gkarri/githubMigration

filename=${repoNameFilePath}/repoNames.txt

while read -r line && [ "$line" != "" ];
do   

REPO_NAME="$line"

git clone git@github.com:gopalreddykarri/$REPO_NAME.git --bare

cd $REPO_NAME

git remote set-url origin git@github.enterprise.com:gopalreddykarri/${REPO_NAME}.git 

git push enterprise --mirror

validateRecentCommitSHA

validateTags

echo "CONTINUE..."
cd ..

done < "$filename"


function validateRecentCommitSHA(){

    echo "Proceed to Validate Most Recent commits SHA... "

    COMMIT_GIT=`git ls-remote git@github.com:gopalreddykarri/${REPO_NAME}.git refs/heads/master | awk '{print $1}'`

    COMMIT_GIT_ENTERPRISE=`git ls-remote git@github.enterprise.com:gopalreddykarri/${REPO_NAME}.git refs/heads/master | awk '{print $1}'`

    if [[  -z "$COMMIT_GIT" || -z "$COMMIT_GIT_ENTERPRISE" ]] || [[ $COMMIT_GIT != $COMMIT_GIT_ENTERPRISE ]]; then

        echo "ERROR : COMMIT NUMBERS OF REPOS NOT MATCHING OR EMPTY for ${REPO_NAME} !!!!!!!!!!!!"
    fi

}

function validateTags(){

    echo "PROCEEDING TO VALIDATE TAGS..."

    TAG_COUNT=`curl -s -u username:token https://api.github.com/repos/gopalreddykarri/${REPO_NAME}/tags | grep '"name":' | wc -l`
    TAG_COUNT_ENTERPRISE=`curl -s -u username:token https://api.github.enterprise.com/repos/gopalreddykarri/${REPO_NAME}/tags | grep '"name":' | wc -l`

    if [[ "$TAG_COUNT" != "$TAG_COUNT_ENTERPRISE" ]]; then

         echo "ERROR : TAG COUNT MISTMATCH FOR ${REPO_NAME} !!!!!!!!!!!!"

    fi

}







