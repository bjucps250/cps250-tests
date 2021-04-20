require-files findconn.py 

exit-if-must-pass-tests-failed

require-pdf report.pdf

cp $TEST_DIR/readblah.so .

run-program --test-message "findconn.py executes with no errors" --showoutputonpass python3 findconn.py $TEST_DIR/testdata

if [ -e findconn_xc.py ]; then
  run-program --test-message "findconn_xc.py executes with no errors" --showoutputonpass python3 findconn_xc.py $TEST_DIR/testdata
else
  echo "No findconn_xc.py found..."
fi


exit 0
