#!/bin/bash

echo $GITHUB_REPOSITORY > log.txt

project=$(echo $GITHUB_REPOSITORY | cut -d/ -f2 | cut -d- -f2)

image=checkmark.svg
if [ -e $project ]
then
    pushd $project    
    if bash runtests.sh >>../log.txt 2>&1
    then
        echo Success        
    else
        echo Failure
        image=fail.svg
    fi
    popd
fi

cat > ../submission/README.md <<EOF
# Submission Status

Test results for submission at $(date)

![](https://raw.githubusercontent.com/sschaub/ssdemo/master/.github/$image)
```
$(cat log.txt)
```
EOF

cd ../submission
git config --local user.email "action@github.com"
git config --local user.name "GitHub Action"
git add README.md 
git commit -m "Automatic Tester Results"
git push
