function runit {
    echo "******************************************************"
    echo Executing $*...
    echo "------------------------------------------------------"
    $*
}

sudo apt-get install -y libbsd-dev

require-files httpv.c Makefile

# ---- Compile --------

result=$PASS
COMPILE_CMD="make"
echo $COMPILE_CMD
echo -n "Result: "
if detail=$($COMPILE_CMD 2>&1); then
    if [ ! -e httpv ]; then
        result=$FAIL
        detail="No executable httpv produced from make"
    fi
else
    result=$FAIL
fi

echo $result
if [ $result = $FAIL ]; then
    echo "----------------------------------------------------------------"
    echo "$detail"
    echo "----------------------------------------------------------------"
fi

report-result $result "$CAT_MUST_PASS" "Compile check"

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

report-result $result "Warnings" "Unsafe string function check"

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


