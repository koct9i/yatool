#!/bin/bash
set -eu -o pipefail

image="debian:stable"
cmd="apt update >&2; apt install -y ca-certificates >&2; cat /etc/ssl/certs/ca-certificates.crt"

mv cacert.pem old-cacert.pem

docker run -i --rm --network=host --pull=always "$image" bash -eux -c "$cmd" >cacert.pem

[ -f internal-cacert.pem ] && cat internal-cacert.pem >>cacert.pem

while openssl x509 -noout -subject -fingerprint; do :; done <old-cacert.pem >old-cacert.txt
while openssl x509 -noout -subject -fingerprint; do :; done <cacert.pem >cacert.txt
diff -y <(sort <old-cacert.txt) <(sort <cacert.txt)
