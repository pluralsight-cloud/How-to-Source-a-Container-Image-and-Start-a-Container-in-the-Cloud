#!/bin/bash

#Install apache2-utils
apt install -y apache2-utils

#Setup some needed directories
mkdir -p /opt/registry/{auth,certs,data}
mkdir -p /etc/docker/certs.d/server-1:5000/

#Generate a certificate
openssl req -newkey rsa:4096 -nodes -sha256 -keyout /opt/registry/certs/domain.key -x509 -days 365 -out /opt/registry/certs/domain.crt -addext 'subjectAltName = DNS:localhost, DNS:sec-registry, DNS:server-1' -subj '/C=US/ST=Washington/L=Seattle/O=ACG/OU=Podman/CN=server-1'

#Copy the cert to local system for docker and general use
cp /opt/registry/certs/domain.crt /etc/docker/certs.d/server-1\:5000/ca.crt
cp /opt/registry/certs/domain.crt /usr/local/share/ca-certificates/ca.crt
update-ca-certificates

#Set a temporary pass for cloud_user
htpasswd -bBc /opt/registry/auth/htpasswd cloud_user badpass

#Start the registry on port 5000 using 2.8.1 image
docker run --name myregistry -p 5000:5000 -v /opt/registry/data:/var/lib/registry:z -v /opt/registry/auth:/auth:z -e REGISTRY_AUTH=htpasswd -e REGISTRY_AUTH_HTPASSWD_REALM="Registry Realm" -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd -v /opt/registry/certs:/certs:z  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key -e REGISTRY_COMPATIBILITY_SCHEMA1_ENABLED=true -d docker.io/library/registry:2.8.1
