cp $TEST_DIR/*.in .


if [ ! -z "$(ls *.c 2>/dev/null)" ]; then

  for CFILE in *.c 
  do
    XFILE=${CFILE%.*}
    echo Compiling $CFILE...
    rm $XFILE 2>/dev/null
    CMD="gcc -std=c99 $CFILE -lbsd -o$XFILE"
    do-compile --test-message "Successful compile of $CFILE" "$CMD" "$XFILE"
  done

fi

result=$FAIL
for prog in check findword ema
do

  if [ -r $prog -o -r $prog.py -o -r $prog.sh ]; then
    if [ -r $prog ]; then
      CMD="./$prog"
    elif [ -r $prog.py ]; then
      CMD="python3 $prog.py"
    else
      CMD="bash $prog.sh"
      dos2unix $prog.sh
    fi

    if [ "$prog" = "check" ]; then
      CMD="$CMD README.md /bin/ls ema1.in"
    elif [ "$prog" = "findword" ]; then
      CMD="$CMD config findword*.in"
    else
      CMD="$CMD ema1.in"
    fi
    
    run-program --test-message "$prog executes with no errors" --showoutputonpass "$CMD"
    result=$PASS
  else
    echo "No $prog submission detected"
  fi

done

report-result $result "Must Pass" "At least one correctly named file submitted"
