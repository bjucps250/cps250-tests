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

exit-if-must-pass-tests-failed

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
      CMD="$CMD /etc/resolv.conf /bin/ls /etc/aliases"
    elif [ "$prog" = "findword" ]; then
      CMD="$CMD config /etc/*.conf"
    else
      CMD="$CMD $TEST_DIR/ema.in"
    fi
    
    run-program --test-message "$prog executes with no errors" --showoutputonpass "$CMD"
  else
    echo "No $prog submission detected"
  fi

done
