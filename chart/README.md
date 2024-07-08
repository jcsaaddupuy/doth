# about

Dns over Tls / Dns over Https chart with support for DNS blocklist.




```
/usr/bin/minikube tunnel -c
```


## Expose without minikube tunnel
```sh
kubectl patch svc kong-gateway-proxy -n kong --patch  '{"spec":{"externalIPs": ["'$(minikube ip)'"]}}'
```

## nginx in front


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
    }
```