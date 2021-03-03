function runit {
    echo "******************************************************"
    echo Executing $*...
    echo "------------------------------------------------------"
    $* | head -20
}

require-files httpv.c Makefile

do-compile "make" "httpv"

exit-if-must-pass-tests-failed

require-pdf report.pdf

# ----- Check for forbidden string functions ---------

result=PASS
echo -e "\nChecking for forbidden string functions..."
for func in strcpy strncpy strcat strncat sprintf
do
  if grep $func httpv.c >/dev/null
  then
    result=FAIL
    echo "* $func detected"
  fi
done

report-result $result "Warnings" "No unsafe string functions"

cp $TEST_DIR/*.txt .

echo "------------------------------------------------------"
echo "Executing ./httpv < goodhttp01.txt..."
echo "------------------------------------------------------"
./httpv < goodhttp01.txt


runit ./httpv missingfile.txt

for FILE in good*.txt bad*.txt 
do
  runit ./httpv $FILE
done


