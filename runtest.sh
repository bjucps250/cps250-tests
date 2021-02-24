#!/bin/bash

echo $GITHUB_REPOSITORY > log.txt

project=$(echo $GITHUB_REPOSITORY | cut -d/ -f2 | cut -d- -f2)

if [ -e $project ]
then
    pushd $project
    if bash runtests.sh >>log.txt 2>&1
    then
        echo Success
    else
        echo Failure
    fi
    popd
fi

cat > ../submission/README.md <<EOF
# README

Test results for submission at $(date)

EOF

cd submission
git config --local user.email "action@github.com"
git config --local user.name "GitHub Action"
git add README.md 
git commit -m "Automatic Tester Results"
git push
