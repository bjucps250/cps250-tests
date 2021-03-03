#!/bin/bash

# To use this script to simulate a github check:
#   cd student-submission
#   runi
#   bash tests/rungh_local.sh lab1

export BASEDIR=/.
. ../tests/util/utils.sh

if [ -z "$1" ]; then
  echo Usage: rungh_local.sh asmt_code
  exit 1
fi

project=$1
TEST_DIR=$TEST_BASE_DIR/$project

# Cleanup previous test results if we're running in the same Docker container
test -f $TEST_RESULT_FILE && rm $TEST_RESULT_FILE
test -d /submission && rm -r /submission

# Setup current test folder
cp -r /submission_src /submission

export GITHUB_REPOSITORY=cps250-$project-foo
bash -xv ../tests/rungh.sh

cp /submission/README.md /submission_src
