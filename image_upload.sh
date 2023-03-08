#!/bin/bash
echo badpass | docker login -u cloud_user --password-stdin server-1:5000
docker pull docker.io/library/nginx
docker run -d --name=temp -p 8080:80 docker.io/library/nginx
docker exec temp bash -c "apt-get update && apt-get install -y vim"
docker exec temp bash -c "echo 'Replace Me' > /usr/share/nginx/html/index.html"
docker stop temp
docker commit temp server-1:5000/nginx:useme
docker push server-1:5000/nginx:latest
docker push server-1:5000/nginx:useme
docker stop temp
docker rm temp
docker pull docker.io/library/mysql
docker tag mysql server-1:5000/llama-web-db:v1
docker tag server-1:5000/llama-web-db:v1 server-1:5000/llama-web-db:v1.2
docker tag server-1:5000/llama-web-db:v1 server-1:5000/llama-web-db:v1.3
docker tag server-1:5000/llama-web-db:v1 server-1:5000/llama-web-db:dev-1.2
docker push server-1:5000/llama-web-db:v1
docker push server-1:5000/llama-web-db:v1.2
docker push server-1:5000/llama-web-db:v1.3
docker push server-1:5000/llama-web-db:dev-1.2
docker rmi nginx mysql server-1:5000/nginx:useme server-1:5000/llama-web-db:v1 server-1:5000/llama-web-db:v1.2 server-1:5000/llama-web-db:v1.3 server-1:5000/llama-web-db:dev-1.2
docker logout server-1:5000

touch /tmp/image_up_done
