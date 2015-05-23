#!/bin/bash
echo "building petclinic"
mvn clean install

echo "Copying docker files"
cp docker/* target/

echo "Building Docker image"
cd target/
docker build -t wouterla/docker-petclinic .

echo "Pushing docker image to repository"
#docker push wouterla/docker-jenkins
