#!/bin/bash

echo $GITHUB_REPOSITORY

project=$(echo $GITHUB_REPOSITORY | cut -d/ -f2 | cut -d- -f2)

echo Checking $project
echo Current dir is $(pwd)
ls -l
python3 -v

