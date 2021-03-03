
require-files args.c

# ---- Compile --------

do-compile "gcc -g  $TEST_DIR/ex3_args_test.c args.c -oargs -lbsd"

exit-if-must-pass-tests-failed

require-pdf report.pdf

# ----- Check for forbidden string functions ---------

result=$PASS
echo -e "\nChecking for forbidden string functions..."
for func in strcpy strncpy strcat strncat sprintf
do
  if grep $func args.c >/dev/null
  then
    result=$FAIL
    echo "* $func detected"
  fi
done

report-result $result "Warnings" "No unsafe string functions"

run-program --test-message "valgrind executes with no errors" --showoutputonpass valgrind ./args

[ $result = $PASS ]
