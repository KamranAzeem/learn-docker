#!/bin/bash
# This script generates SSL certs (.crt and .key) to be used with nginx.
# The files are generated in .PEM format.

echo
echo "Usage: $0 [domainname]"
echo

if [ -n "$1" ]; then
  DOMAIN_NAME="$1"
else
  echo "No domainname provided. Using example.com as domainname ..."
  DOMAIN_NAME="example.com"
fi

echo
echo "Generating self signed certificate for ${DOMAIN_NAME} ..."
openssl req \
  -x509 -newkey rsa:2048 -nodes -days 365 \
  -keyout tls.key -out tls.crt -subj "/CN=*.${DOMAIN_NAME}"

echo
echo "SSL certification creation for ${DOMAIN_NAME} complete."

#echo "Creating a combined PEM file out of the two certificate files ... (in case you need it later)"
#cat tls.crt tls.key > tls-cert-plus-key.pem
#echo
echo "Here are the generated certificate files:"
ls -l tls.*



