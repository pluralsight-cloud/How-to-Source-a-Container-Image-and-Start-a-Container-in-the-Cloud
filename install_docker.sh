#!/bin/bash

#Kill the stupid unattended upgrade (if still running)
/usr/bin/pgrep unatte | xargs -n 1 kill
/usr/bin/fuser -k /var/lib/dpkg/lock-frontend

#install lsof
apt install -y lsof

#lsof /var/lib/dpkg/lock-frontend
LSOF_STATUS=0
until [ $LSOF_STATUS -ne 0 ];
do
        echo locked
        sleep 2
        lsof /var/lib/dpkg/lock-frontend
        LSOF_STATUS=$?
done

apt-get update
apt install -y ca-certificates curl gnupg lsb-release

#Add Docker GPG key
mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

#Set up the repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

#Install Docker Engine
apt-get update

apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

#Add cloud_user to docker group
usermod -aG docker cloud_user

touch /tmp/docker_done
