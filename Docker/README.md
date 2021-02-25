
To publish to https://hub.docker.com/repository/docker/bjucps/cps209-codepost-java:

Change the 'v1' in the following to the next version number: 

docker login --username=sschaub
docker tag e601e8482ce5 bjucps/cps209-codepost-java:v1
docker push bjucps/cps209-codepost-java:v1

Then, must update codepost Docker definitions to reference new tag
