#!/bin/bash

#Start the initial container
docker run -d --name web-1 -p 8081:80 nginx

#Install vim in the container
docker cp /etc/apt/sources.list web-1:/etc/apt/sources.list
docker exec web-1 bash -c "apt-get update"
docker exec web-1 bash -c "apt install -y vim"

touch /tmp/web-1_done
