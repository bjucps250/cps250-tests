
require-files args.c

# ---- Compile --------

do-compile --always-show-output "gcc -g  $TEST_DIR/ex3_args_test.c args.c -oargs -lbsd"

exit-if-must-pass-tests-failed

require-pdf report.pdf

forbidden-string-function-check args.c

run-program --test-message "valgrind executes with no errors" --showoutputonpass valgrind ./args | sed 's/^==[^=]*==/====/'

