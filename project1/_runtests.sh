SERVER_LOG=/tmp/serverlog.txt

function dump-server-log {
  echo -e "\n--------------------------------------------------------------------"
  echo "Server log:"
  echo "--------------------------------------------------------------------"
  tail -20 $SERVER_LOG 

}

require-files Makefile webserver.c
require-files --test-category "Warning" --test-message "utils.c submitted" utils.c

[ -r webserver ] && rm webserver *.o
do-compile "make release" "webserver"

exit-if-must-pass-tests-failed

cp $TEST_DIR/file* .

require-pdf report.pdf

forbidden-string-function-check *.c

# -------------------------------------
# Start web server

echo -e "\nWeb server functionality tests"
echo -e "----------------------------------------"
cmd="./webserver -p 8080 -r ."
echo "Starting web server: $cmd"
$cmd >$SERVER_LOG 2>&1  &
sleep 2
result=$FAIL
if stdout=$(ps | grep webserver); then
  result=$PASS
fi
report-result $result "$CAT_MUST_PASS" "Successful server start"
echo -e "\nChecking for successful server start... $result"
if [ $result = $FAIL ]; then
  dump-server-log
  exit
fi

# ------------------------------------------
# Check to see if it responds to valid request

result=$FAIL
get="GET /file1.txt HTTP/1.0\r\n\r\n"
echo -e "\nSending GET to server: $get"
if stdout=$(echo -en "$get" | timeout 1 nc localhost 8080 2>&1 >/tmp/test1.out); then
  echo ''
else
  if [ $? -eq 124 ]; then
    echo ---- Timeout waiting for response ----  >> /tmp/test1.out
  fi
fi

echo -e "\nExpected Result                       | Actual Result"
echo -e "------------------------------------------------------------------------------"
tr -d '\r' < /tmp/test1.out > /tmp/test1.out2
if diff -yZit -W 80 $TEST_DIR/test1.exp /tmp/test1.out2; then
  result=$PASS
else
  result=$FAIL
fi

report-result $result "$CAT_MUST_PASS" "Correct server response to valid request"

kill $(ps | grep webserver | awk ' {print $1} ')
sleep 1

dump-server-log

