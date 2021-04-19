#!/bin/bash

# This script is used by the runp1 script to start the server running in a docker container for my local testing...

cp -r /submission_src /submission
cp -r /wwwroot_src /wwwroot
cd /submission
make release && valgrind ./webserver -r /wwwroot -p 5000 -h 0.0.0.0
