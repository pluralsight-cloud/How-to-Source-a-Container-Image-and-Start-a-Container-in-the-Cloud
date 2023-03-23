#!/bin/bash

#Set colors
export red="\033[1;31m"
export green="\033[1;32m"
export reset="\033[m"

#Set cloud pass and ssh options
export CLOUDPASS=`cat /tmp/cloud_pass`
export SSHOPTIONS='StrictHostKeyChecking=no cloud_user@10.0.2.101'

#Check for the running containers
sshpass -p $CLOUDPASS ssh -o $SSHOPTIONS 'docker ps | grep " web-dev$" 2>&1 > /dev/null'
WEB_DEV_CONTAINER_STATUS=$?

sshpass -p $CLOUDPASS ssh -o $SSHOPTIONS 'docker ps | grep " llama-racing-web$" 2>&1 > /dev/null'
LLAMA_CONTAINER_STATUS=$?


if [ $WEB_DEV_CONTAINER_STATUS -eq 0 ]; then
	echo -e "Check if container web-dev Exists ${green}[passed]${reset} "
else
	echo -e "Check if container web-dev Exists ${red}[failed]${reset} "
fi

if [ $LLAMA_CONTAINER_STATUS -eq 0 ]; then
        echo -e "Check if llama-racing-web Exists ${green}[passed]${reset} "
else
        echo -e "Check if llama-racing-web Exists ${red}[failed]${reset} "
fi

#Check the content file hashes
INDEX_HASH_CONTAINER=$(sshpass -p $CLOUDPASS ssh -o $SSHOPTIONS 'docker exec llama-racing-web bash -c "md5sum /usr/share/nginx/html/index.html"' | awk '{print $1}') 
INDEX_HASH="0e474e8e87ad5694eb063dd837fad123"

WEBP_HASH_CONTAINER=$(sshpass -p $CLOUDPASS ssh -o $SSHOPTIONS 'docker exec llama-racing-web bash -c "md5sum /usr/share/nginx/html/llama_racecar.webp"' | awk '{print $1}') 
WEBP_HASH="62ee0247e61350419de5edd3edc51412"

if [[ $WEBP_HASH_CONTAINER == $WEBP_HASH && $INDEX_HASH_CONTAINER == $INDEX_HASH ]]; then
	echo -e "Check if /usr/share/nginx/html files are correct ${green}[passed]${reset} "
else
	echo -e "Check if /usr/share/nginx/html files are correct ${red}[failed]${reset} "
fi

#Check for image on server-1:5000 registry
sshpass  -p $CLOUDPASS ssh -o $SSHOPTIONS 'export CLOUDPASS=`cat cloud_pass` ; curl -s -K <(echo user=cloud_user:"$CLOUDPASS") https://server-1:5000/v2/_catalog | python -m json.tool | grep "llama-racing\",$" 2>&1 > /dev/null'
IMAGE_EXISTS=$?
sshpass  -p $CLOUDPASS ssh -o $SSHOPTIONS 'export CLOUDPASS=`cat cloud_pass` ; curl -s -K <(echo user=cloud_user:"$CLOUDPASS") https://server-1:5000/v2/llama-racing/tags/list | python -m json.tool | grep "v1\"$" 2>&1 > /dev/null'
TAG_EXISTS=$?

if [ $IMAGE_EXISTS -eq 0 ]; then
	echo -e "Check if llama-racing Repo Exists on server-1:5000 ${green}[passed]${reset} "
else
	echo -e "Check if llama-racing Repo Exists on server-1:5000 ${red}[failed]${reset} "
fi

if [ $TAG_EXISTS -eq 0 ]; then
        echo -e "Check if llama-racing Repo Tag Exists on server-1:5000 ${green}[passed]${reset} "
else
        echo -e "Check if llama-racing Repo Tag Exists on server-1:5000 ${red}[failed]${reset} "
fi

#Check if new web-page is availabel
sshpass -p $CLOUDPASS ssh -o $SSHOPTIONS 'curl -s server-1:8080 | grep "Club" 2>&1 > /dev/null'
WEB_WORKS=$?

if [ $WEB_WORKS -eq 0 ]; then
        echo -e "Check if llama-racing web-page works on server-1:5000 ${green}[passed]${reset} "
else
        echo -e "Check if llama-racing web-page works on server-1:5000 ${red}[failed]${reset} "
fi
