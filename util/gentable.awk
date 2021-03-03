#!/usr/bin/awk 

/^PASS/ { print $2 "|" $3 "|![PASS](https://raw.githubusercontent.com/bjucps250/cps250-tests/master/images/pass.png)" }
/^FAIL/ { print $2 "|" $3 "|![FAIL](https://raw.githubusercontent.com/bjucps250/cps250-tests/master/images/fail.png)" }
