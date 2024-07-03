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

{{- range .config.blocklists }}
echo "Fetching {{.name}} ..."
curl -s '{{.url}}' | \
	grep ^{{.hostFileIpPattern | default "0.0.0.0"}} - | \
        sed 's/ #.*$//;
        s/^{{.hostFileIpPattern | default "0.0.0.0"}} \(.*\)/local-zone: "\1" refuse/' \
        >> blacklist.conf;
{{- end }}


echo "$(cat blacklist.conf | wc -l) domains blocked"
echo "All good !"
