
docker run -it --rm -v %cd%:/submission_src -v C:\teaching\cps250\class\project1:/wwwroot_src -v %~dp0:/tests -p 8000:5000  bjucps/cps250-test bash tests/project1/_launch.sh

:done