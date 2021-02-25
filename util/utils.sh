#!/bin/bash

export TEST_RESULT_FILE=$BASEDIR/_testresults.log
export LOG_FILE=$BASEDIR/_log.txt
export TEST_BASE_DIR=$BASEDIR/tests
#export TEST_DIR=   # Must be set by script
#export SUBMISSION_DIR=   # Must be set by script
export TIMEOUT=5  # default timeout in seconds

# Constants
CAT_MUST_PASS="Must Pass"
PASS="PASS"
FAIL="FAIL"

touch $TEST_RESULT_FILE  # Create if it doesn't exist

# Usage: report-error test-category test-name 
function report-error {
    echo "FAIL~$1~$2" >> $TEST_RESULT_FILE
}

# Usage: report-error PASS|FAIL test-category test-name detail-msg
function report-result {
    echo "$1~$2~$3" >> $TEST_RESULT_FILE
}

function fatal-errors-exist {
    grep "^$FAIL~$CAT_MUST_PASS" $TEST_RESULT_FILE >/dev/null
}

function run-tests {
    # Read test config if it exists
    if [ -r $TEST_DIR/config.sh ]; then
      . $TEST_DIR/config.sh
    fi

    result=FAIL
    if BASH_ENV=$TEST_BASE_DIR/util/utils.sh timeout -k $TIMEOUT $TIMEOUT bash _runtests.sh >$LOG_FILE 2>&1
    then
        fatal-errors-exist && result=FAIL
    else
        if [ $? -eq 124 ]; then
          report-error "$CAT_MUST_PASS" "Complete all tests within $TIMEOUT seconds"
        else
          report-error "$CAT_MUST_PASS" "Complete basic tests successfully"
        fi
        result=FAIL
    fi

}

function gen-readme {
    cat > $SUBMISSION_DIR/README.md <<EOF
# Submission Status

Test results for submission at **$(TZ=America/New_York date)**

Category | Test | Result
---------|------|-------
$(awk -F~ -f $TEST_BASE_DIR/util/gentable.awk $TEST_RESULT_FILE)

## Detailed Test Results
\`\`\`
$(cat $LOG_FILE)
\`\`\`
EOF

}

function require-files {
    local result

    result=$PASS
    for file in $*
    do
        echo -n "Checking for required file $file... "
        if [ -r $file ]; then
            echo $PASS
        else
            echo "$FAIL - not found"
            result=$FAIL
        fi
    done

    report-result $result "$CAT_MUST_PASS" "Required Files Submitted"

}

function require-pdf {
    local result
    local reason

    result=PASS
    for file in $*
    do
        echo -n "Checking for required PDF $file... "
        if [ ! -r $file ]; then
            echo "FAIL - $file is not found"
            result=$FAIL
        elif file $file | grep PDF >/dev/null; then
            echo "PASS"
        else
            echo "FAIL - $file is not a valid PDF"
            result=$FAIL
        fi
    done

    report-result $result "$CAT_MUST_PASS" "Required PDF submitted" 

}

