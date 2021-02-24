#!/bin/bash

echo $GITHUB_REPOSITORY > log.txt

project=$(echo $GITHUB_REPOSITORY | cut -d/ -f2 | cut -d- -f2)

if [ -e $project ]
then
    pushd $project
    if bash $project.sh >>log.txt 2>&1
    then
        echo Success
    else
        echo Failure
    fi
    popd
fi

echo > submission/README.md <<<EOF
# README

Test results for submission at $(date)
```
$(cat log.txt)
```
EOF

cd submission
git config --local user.email "action@github.com"
git config --local user.name "GitHub Action"
git add README.md 
git commit -m "Add/Update badge"
git push
