
require-files Makefile webserver.c
require-files --test-category "Warning" --test-message "utils.c submitted" utils.c

do-compile "make" "webserver"

exit-if-must-pass-tests-failed

require-pdf report.pdf

forbidden-string-function-check *.c

# -------------------------------------
# Start web server

echo -e "\nWeb server functionality tests"
echo -e "----------------------------------------"
cmd="./webserver -p 8080 -r ."
echo "Starting web server: $cmd"
$cmd >/tmp/serverlog.txt 2>&1  &
sleep 2
result=$FAIL
if stdout=$(ps | grep webserver); then
  result=$PASS
fi
report-result $result "$CAT_MUST_PASS" "Successful server start"
echo "Checking for successful server start... $result"
if [ result = $FAIL ]; then
  echo "Server log: " 
  cat /tmp/serverlog.txt
  exit 1
fi

# ------------------------------------------
# Check to see if it serves a file

result=$FAIL
get="GET /_file1.txt HTTP/1.0\r\n\r\n"
echo "Sending GET to server: $get"
if stdout=$(echo -en "$get" | timeout 1 nc localhost 8080 >/tmp/test1.out 2>&1); then
  echo -e "\nExpected Result              |  Actual Result"
  echo -e "--------------------------------------------------------------------"
  if diff -y -W 60 $TEST_DIR/test1.exp /tmp/test1.out; then
    result=$PASS
  else
    result=$FAIL
  fi
else
  echo "Result: $stdout"
fi
report-result $result "$CAT_MUST_PASS" "Server serves file correctly"

kill $(ps | grep webserver | awk ' {print $1} ')
sleep 1
echo "Server log:"
cat /tmp/serverlog.txt

