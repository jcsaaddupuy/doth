# about

Dns over Tls / Dns over Https chart with blocklist.


## install haproxy
helm install haproxy haproxytech/kubernetes-ingress -n doth


##

```
openssl req -x509 -newkey rsa:2048 -keyout example.key -out example.crt -days 365 -nodes -subj "/C=US/ST=Ohio/L=Columbus/O=MyCompany/CN=example.com
```

```
kubectl create secret tls example-cert --cert="example.crt" --key="example.key" -n doth
```