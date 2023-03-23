#!/bin/bash

CLOUDPASS=`cat /home/cloud_user/cloud_pass`
#Start container
echo "$CLOUDPASS" | docker login -u cloud_user --password-stdin server-1:5000
docker run -dt --name checker debian:buster
docker cp /etc/apt/sources.list checker:/etc/apt/
docker cp cloud_pass checker:/tmp/
docker cp /tmp/check_final.sh checker:/tmp/
docker exec checker bash -c "apt-get update && apt install -y -qq vim ssh sshpass"
docker exec checker bash -c "chmod +x /tmp/check_final.sh"
docker stop checker
docker commit checker server-1:5000/checker:latest
docker push server-1:5000/checker:latest
docker rm checker
docker rmi debian:buster server-1:5000/checker:latest
docker logout server-1:5000
