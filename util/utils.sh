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

function must-pass-tests-failed {
    grep "^$FAIL~$CAT_MUST_PASS" $TEST_RESULT_FILE >/dev/null
}

function exit-if-must-pass-tests-failed {
    must-pass-tests-failed && exit 1
}

# Returns 0 on success, 1 on failure
function run-tests {
    # Read test config if it exists
    if [ -r $TEST_DIR/config.sh ]; then
      . $TEST_DIR/config.sh
      if [ -n "$INSTALL_PACKAGES" ]; then
        sudo apt-get install -qq $INSTALL_PACKAGES
      fi
    fi

    result=0
    if BASH_ENV=$TEST_BASE_DIR/util/utils.sh timeout -k $TIMEOUT $TIMEOUT bash _runtests.sh >$LOG_FILE 2>&1
    then
        must-pass-tests-failed && result=1
    else
        if [ $? -eq 124 ]; then
          report-error "$CAT_MUST_PASS" "Complete all tests within $TIMEOUT seconds"
        else
          report-error "$CAT_MUST_PASS" "Complete basic tests successfully"
        fi
        result=1
    fi

    return $result
}

function gen-readme {

    echo $1 >$SUBMISSION_DIR/submission.status

    if [ $1 = "PASS" ]; then
        icon=https://raw.githubusercontent.com/bjucps250/cps250-tests/master/images/pass.png
    else
        icon=https://raw.githubusercontent.com/bjucps250/cps250-tests/master/images/fail.png
    fi

    cat > $SUBMISSION_DIR/README.md <<EOF
# Submission Status ![]($icon)

Test results generated at **$(TZ=America/New_York date)**

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

