#!/bin/bash

#Start container
docker run -dt --name checker debian:buster
docker cp /etc/apt/sources.list checker:/etc/apt/
docker cp /root/cloud_pass checker:/tmp/
#docker cp check_final.sh checker:/tmp/
docker exec checker bash -c "apt-get update && apt install -y -qq vim ssh sshpass wget"
docker exec checker bash -c "wget https://github.com/pluralsight-cloud/How-to-Source-a-Container-Image-and-Start-a-Container-in-the-Cloud/raw/main/check_final.sh -P /tmp/"
docker exec checker bash -c "chmod +x /tmp/check_final.sh"
docker exec checker bash -c "chown 777 /tmp/cloud_pass"
docker stop checker
docker commit checker server-1:5000/checker:latest
docker rm checker
docker rmi debian:buster 
docker run -t --name checker server-1:5000/checker:latest /tmp/check_final.sh
touch /tmp/checker_done
