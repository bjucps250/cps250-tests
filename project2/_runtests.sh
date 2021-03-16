
require-pdf report.pdf

if [ -e Makefile ]; then

  rm *.o sysman >/dev/null 2>&1
  do-compile make sysman
  exit-if-must-pass-tests-failed

elif [ -r sysman -a -r sysman.py ]; then 

  chmod +x sysman

else

  report-error "$CAT_MUST_PASS" "Either Makefile (C) or sysman and sysman.py (Python) submitted"
  exit 0

fi

run-program --test-message "sysman executes with no errors" --showoutputonpass ./sysman --sysinfo

exit 0
