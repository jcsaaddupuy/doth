#! /usr/bin/env sh
set -e
set -u
set -o pipefail

echo "Current directory : $(pwd)"

echo "# Generated on $(date)" > blacklist.conf
echo "server:" >> blacklist.conf

# canary domain for healthcheck
CANARY_DOMAIN=${CANARY_DOMAIN:-"blockme.localhost"}
echo "local-zone: \"${CANARY_DOMAIN}\" refuse" >> blacklist.conf

echo "Fetching StevenBlack ..."
curl -s 'https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts' | \
	grep ^0.0.0.0 - | \
        sed 's/ #.*$//;
        s/^0.0.0.0 \(.*\)/local-zone: "\1" refuse/' \
        >> blacklist.conf;


echo "$(cat blacklist.conf | wc -l) domains blocked"
echo "All good !"
