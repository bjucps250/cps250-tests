#!/bin/bash

# This script runs in my GitHub Docker container. It sets up the
# folder structure for a submission test and runs the test, then copies test results
# to the student folder

export BASEDIR=$(pwd)
. tests/util/utils.sh

if [ ! -d submission ]; then
  echo "No submission folder found"
  exit 1
fi

# Rest of script runs in submission folder
cd submission
export SUBMISSION_DIR=$(pwd)

# Extract project name from GITHUB_REPOSITORY value
# GITHUB_REPOSITORY should be of the form (ex.) cps250-project-student_reponame
project=$(echo $GITHUB_REPOSITORY | cut -d/ -f2 | cut -d- -f2)
echo "$project submission detected"

export TEST_DIR=$TEST_BASE_DIR/$project

result=PASS
if [ -e $TEST_DIR/_runtests.sh ]
then
    # Copy test files to submission folder
    cp -r $TEST_DIR/_* .

    run-tests
else
    echo No tests for $project submissions... >$LOG_FILE
fi

git config --local user.email "action@github.com"
git config --local user.name "GitHub Action"
git pull

# Generate report
gen-readme

git add README.md 
git commit -m "Automatic Tester Results"
git push

test $result = PASS
