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

project=$(get-project-name)
echo "$project submission detected"

export TEST_DIR=$TEST_BASE_DIR/$project

if [ -e $TEST_DIR/_runtests.sh ]
then
    # Copy test files to submission folder
    cp -r $TEST_DIR/_* .

    run-tests || report-error "Warning" "Test script completed successfully"
else
    echo No tests have been defined for $project submissions... >$LOG_FILE
fi

# Generate report

echo "Publishing README.md..."

git config --local user.email "action@github.com"
git config --local user.name "GitHub Action"
git config pull.rebase false  # merge (the default strategy)

git pull 

gen-readme

git add README.md submission.status
git commit -m "Automatic Tester Results"

git push


