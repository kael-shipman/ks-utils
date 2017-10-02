#!/bin/bash

# Bash shell script for generating self-signed certs. Run this in a folder, as it
# generates a few files. Large portions of this script were taken from the
# following artcile:
# 
# http://usrportage.de/archives/919-Batch-generating-SSL-certificates.html
# 
# Additional alterations by: Brad Landers
# Date: 2012-01-27

# Script accepts a single argument, the fqdn for the cert
DOMAIN="$1"
SUBJ="$2"
if [ -z "$DOMAIN" -o -z "$SUBJ" ]; then
  echo "Usage: $(basename $0) <domain> <subj>"
  echo 'An example of a subject string is "/C=US/ST=Illinois/L=Chicago/O=Me/OU=Private/CN=me/emailAddress=kael.shipman@gmail.com"'
  exit 11
fi

fail_if_error() {
  [ $1 != 0 ] && {
    unset PASSPHRASE
    exit 10
  }
}

# Generate a passphrase
export PASSPHRASE=bullphrase

# Certificate details; replace items in angle brackets with your own info

# Generate the server private key
openssl genrsa -des3 -out $DOMAIN.key -passout env:PASSPHRASE 2048
fail_if_error $?

# Generate the CSR
openssl req \
    -new \
    -batch \
    -subj "$(echo -n "$SUBJ" | tr "\n" "/")" \
    -key $DOMAIN.key \
    -out $DOMAIN.csr \
    -passin env:PASSPHRASE
fail_if_error $?
cp $DOMAIN.key $DOMAIN.key.org
fail_if_error $?

# Strip the password so we don't have to type it every time we restart Apache
openssl rsa -in $DOMAIN.key.org -out $DOMAIN.key -passin env:PASSPHRASE
fail_if_error $?

# Generate the cert (good for 10 years)
openssl x509 -req -days 3650 -in $DOMAIN.csr -signkey $DOMAIN.key -out $DOMAIN.crt
fail_if_error $?
