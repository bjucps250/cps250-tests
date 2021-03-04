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

forbidden-string-function-check httpv.c

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


