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
      if [ -n "$INSTALL_PACKAGES" -a -z "$NO_INSTALL_PACKAGES" ]; then
        # Install required packages
        if [[ "$MY_PKG_CACHE_HIT" == 'true' ]]; then
          # Install package files from cache
          echo "Installing package files from cache..."
          sudo cp --force --recursive ~/my-packages/* /
        else
          sudo apt-get update && sudo apt-get install -yq $INSTALL_PACKAGES
          if [ -z "$NO_PACKAGE_CACHE" ]; then
            # Save installed files to my-packages to be cached
            mkdir -p ~/my-packages
            for dep in $INSTALL_PACKAGES; do
                dpkg -L $dep \
                    | while IFS= read -r f; do if test -f $f; then echo $f; fi; done \
                    | xargs cp --parents --target-directory ~/my-packages/
            done
          fi
        fi
        
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

    local final_result=$1

    echo $1 >$SUBMISSION_DIR/submission.status

    if [ $final_result = "$PASS" ]; then
        icon=https://raw.githubusercontent.com/bjucps250/cps250-tests/master/images/pass.png
    else
        icon=https://raw.githubusercontent.com/bjucps250/cps250-tests/master/images/fail.png
    fi

    cat > $SUBMISSION_DIR/README.md <<EOF
# Submission Status ![$final_result]($icon)

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
    local result overallresult

    overallresult=$PASS
    for file in $*
    do
        result=$PASS
        if [ ! -r "$file" ]; then
            result=$FAIL
            overallresult=$FAIL
        fi
        echo "Checking for required file $file... $result"
    done

    report-result $overallresult "$CAT_MUST_PASS" "Required Files Submitted"

}

function require-pdf {
    local overallresult
    local reason

    overallresult=$PASS
    for file in $*
    do
        echo -n "Checking for required PDF $file... "
        if [ ! -r $file ]; then
            echo "$FAIL - $file is not found"
            overallresult=$FAIL
        elif file $file | grep PDF >/dev/null; then
            echo "$PASS"
        else
            echo "$FAIL - $file is not a valid PDF"
            overallresultresult=$FAIL
        fi
    done

    report-result $overallresult "$CAT_MUST_PASS" "Required PDF submitted" 

}

# Compiles a program and reports success or failure
# Usage: do-compile <compile command> [ <expected executable> ]
# Example:
#     do-compile "gcc -g myproc.c -omyprog" "myprog" 
function do-compile {
    local result=$FAIL
    local detail
    local compile_cmd=$1
    local expected_exe=$2

    if detail=$($compile_cmd 2>&1); then
        result=$PASS
        if [ -n "$expected_exe" -a ! -e "$expected_exe" ]; then
            result=$FAIL
            detail="No executable $expected_exe produced from make"
        fi
    fi

    echo -e "\nExecuting: $compile_cmd... $result"
    if [ $result = $FAIL ]; then
        echo "----------------------------------------------------------------"
        echo "$detail"
        echo "----------------------------------------------------------------"
    fi

    report-result $result "$CAT_MUST_PASS" "Successful compile"
 
    [ $result = $PASS ]
}

# Execute a program and report result.
#
# Usage: run-program [ --test-category <category> ] [ --test-message <message> ] [ --timeout <seconds> ] [ --maxlines <lines> ] [ --showoutputonpass ] program args...
#
# * Output of program is normally displayed only if the exit code indicates failure.
#   Use --showoutputonpass to always display output.
# * An entry is added to the test report if --test-message is specified
#
# Example: 
#    run-program --test-message "valgrind executes with no errors" --showoutputonpass valgrind ./args
#
function run-program {
    local testcategory="Warnings" 
    local testmessage
    local timeout=30              # Default timeout
    local showoutputonpass=0 
    local maxlines=50
    local result

    testcategory="Warnings"
    if [ "$1" = "--test-category" ]; then
        testcategory=$2
        shift 2
    fi
    if [ "$1" = "--test-message" ]; then
        testmessage=$2
        shift 2
    fi
    if [ "$1" = "--timeout" ]; then
        timeout=$2
        shift 2
    fi
    if [ "$1" = "--max-lines" ]; then
        maxlines=$2
        shift 2
    fi
    if [ "$1" = "--showoutputonpass" ]; then
        showoutputonpass=1
        shift 
    fi

    result=$FAIL
    if output=$(timeout 30 $* 2>&1 | head -$maxlines); then
        result=$PASS
    fi

    echo -e "\nExecuting: $* ... $result"
    if [ $result = $FAIL -o $showoutputonpass = 1 ]; then
        echo "----------------------------------------------------------------"
        echo "$output"
        echo "----------------------------------------------------------------"
    fi

    if [ -n "$testmessage" ]; then
        report-result $result "$testcategory" "$testmessage"
    fi

    [ $result = $PASS ]
}