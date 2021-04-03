SERVER_LOG=/tmp/serverlog.txt

function dump-server-log {
  echo -e "\n--------------------------------------------------------------------"
  echo "Server log:"
  echo "--------------------------------------------------------------------"
  tail -20 $SERVER_LOG 

}

require-files Makefile 
require-files --test-category "Warning" --test-message "webserver.c, utils.c submitted" webserver.c utils.c

[ -r webserver ] && rm webserver *.o
do-compile "make release" "webserver"

exit-if-must-pass-tests-failed

cp $TEST_DIR/* .

if [ -r CHECKPOINT.md ]; then
  echo "Checkpoint submission detected. No report.pdf required."
else
  require-pdf report.pdf
fi


forbidden-string-function-check $(find . -name '*.c')

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

if [ -r CHECKPOINT.md ]; then
  FILENAME=file1
else
  FILENAME=test1
fi

result=$FAIL
get="GET /$FILENAME.txt HTTP/1.0\r\n\r\n"
echo -e "\nSending GET to server: $get"
echo -en "$get" | timeout 1 nc localhost 8080 2>&1 >/tmp/test1.out
if [ $? -eq 124 ]; then
  echo ---- Timeout waiting for response ----  >> /tmp/test1.out
fi

echo -e "\nExpected Result                         | Actual Result"
echo -e "------------------------------------------------------------------------------"
tr -d '\r' < /tmp/test1.out > /tmp/test1.out2 # Strip any carriage lines out for comparison / reporting purposes
if diff -yZit -W 80 $TEST_DIR/$FILENAME.exp /tmp/test1.out2; then
  result=$PASS
else
  result=$FAIL
fi

report-result $result "Warning" "Correct server response to valid request"

kill $(ps | grep webserver | awk ' {print $1} ')
sleep 1

dump-server-log

