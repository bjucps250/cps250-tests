docker run -it --rm -v %cd%:/submission_src -v %~dp0:/tests  bjucps/cps250-test bash --rcfile /tests/util/bashrc -i
