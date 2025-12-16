# About

DOTH stands for Dns Over Tls/Https.


This chart helps to setup a DNS server with support for 
- DNS over TLS
- DNS over HTTPS


This setup up an authoritative DNS.

# minikube systemd service

```txt
Description=Kickoff Minikube Cluster
After=docker.service

[Service]
Type=oneshot
ExecStart=/usr/bin/minikube start --driver docker --ports 80,853,443 --static-ip 192.168.49.2
RemainAfterExit=true
ExecStop=/usr/bin/minikube stop
StandardOutput=journal
User=minikube
Group=docker

[Install]
WantedBy=multi-user.target
```


## Install

```sh
helm install kong kong/ingress -n kong --create-namespace

helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.15.1 \
  --set crds.enabled=true


helm upgrade --reset-then-reuse-values --version v1.19.1 cert-manager jetstack/cert-manager --namespace cert-manager



# patch kong gateway and service to open port 853
kubectl patch deploy -n kong kong-gateway --patch-file cluster/kong/01-patch-deployment.yaml
kubectl patch service -n kong kong-gateway-proxy --patch-file cluster/kong/02-patch-kong-gateway-proxy.yaml

# install doth
kubectl create ns doth
kubectl apply -f cluster/01-cert-issuers/cert-issuer-prod.yaml -n doth
helm install doth chart --set ingress.rootDomain=your.domain.com -n doth
```

## Expose without minikube tunnel

### Set kong gateway proxy external ip
```sh
kubectl patch svc kong-gateway-proxy -n kong --patch  '{"spec":{"externalIPs": ["'$(minikube ip)'"]}}'
```

Systemd service to update

```
[Unit]
Description=Kickoff Minikube Cluster
After=minikube.service

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'kubectl patch svc kong-gateway-proxy -n kong --patch  \'{"spec":{"externalIPs": ["\'$(/usr/bin/minikube ip)\'"]}}\' '
StandardOutput=journal
User=minikube
Group=minikube

[Install]
WantedBy=multi-user.target
```


### Configure nginx in front

```sh
    user www-data;
    worker_processes auto;
    pid /run/nginx.pid;
    error_log /var/log/nginx/error.log;
    include /etc/nginx/modules-enabled/*.conf;

    events {
            worker_connections 768;
            # multi_accept on;
    }

    # 192.168.49.2 : minikube ip
    # just forward everything to kube on port 80 and 443
    stream {
            server {
                    listen     80;
                    proxy_pass 192.168.49.2:80; 
            }
            server {
                    listen     443;
                    proxy_pass 192.168.49.2:443;
            }
            server {
                    listen     853;
                    proxy_pass 192.168.49.2:853;
            }

            # open 53 TCP/UDP to an internal interface (ex: wireguard)
            server {
                listen     10.8.0.1:53;
                listen     10.8.0.1:53 udp;
                proxy_pass 192.168.49.2:53;
            }

    }
```

# Test config

## test dot using kdig

```
kdig google.fr @ns1.your.domain.com -p 853 +tls +tls-sni=ns1.your.domain.com +short
```


## test doh using curl

```
curl --doh-url https://ns1.your.domain.com/dns-query http://ifconfig.me
```
