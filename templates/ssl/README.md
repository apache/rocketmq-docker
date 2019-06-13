# Description of TLS related files

The purpose of this README file is to show how to generate SSL-related key pairs and self-signed certificates for testing, and how to configure the RocketMQ TLS configuration file parameters.

## 1. Generating SSL related files

### CA certificate and key file generation (directly generate CA key and its self-signed certificate)
```
openssl req -newkey rsa:2048 -passout pass:123456 -keyout ca_rsa_private.pem -x509 -days 365 -out ca.crt -subj "/C=CN/ST=BJ/L=BJ/O=COM/OU=NSP/CN=CA/emailAddress=youremail@apache.com"
```

### Server certificate and key file generation (directly generate server key and certificate to be signed)
```
openssl req -newkey rsa:2048 -passout pass:server -keyout server_rsa_private.pem  -out server.csr -subj "/C=CN/ST=BJ/L=BJ/O=COM/OU=NSP/CN=SERVER/emailAddress=youremail@apache.com"
```

### Signing a server certificate with a CA certificate and key
```
openssl x509 -req -days 365 -in server.csr -CA ca.crt -CAkey ca_rsa_private.pem -passin pass:123456 -CAcreateserial -out server.crt
# Alternatively, convert the encrypted RSA key to an unencrypted RSA key, avoiding the requirement to enter the decryption password for each read.
openssl rsa -in server_rsa_private.pem -out server_rsa_private.pem.unsecure -passin pass:server
```

### Client certificate and key file generation (directly generate client key and certificate to be signed)
```
openssl req -newkey rsa:2048 -passout pass:client -keyout client_rsa_private.pem -out client.csr -subj "/C=CN/ST=BJ/L=BJ/O=COM/OU=NSP/CN=CLIENT/emailAddress=youremail@apache.com"
```

### Signing a client certificate with a CA certificate and key
```
openssl x509 -req -days 365 -in client.csr -CA ca.crt -CAkey ca_rsa_private.pem -passin pass:123456 -CAcreateserial -out client.crt
# Alternatively, convert the encrypted RSA key to an unencrypted RSA key
openssl rsa -in client_rsa_private.pem -out client_rsa_private.pem.unsecure -passin pass:client
```

### PKCS8 processing of the client and server keys (Reason: see Appendix 1)
```
openssl pkcs8 -topk8 -v1 PBE-SHA1-RC4-128 -in  server_rsa_private.pem   -out server_rsa_private_pkcs8.pem  -passout pass:server -passin pass:server
openssl pkcs8 -topk8 -v1 PBE-SHA1-RC4-128 -in client_rsa_private.pem -out client_rsa_private_pkcs8.pem  -passout pass:client -passin pass:client
```

## 2. RocketMQ TLS Configuration Instructions
ssl.properties (Note: there should be no spaces after the attribute value)
```
## client setting
tls.client.certPath=/home/rocketmq/ssl/client.crt
tls.client.keyPath=/home/rocketmq/ssl/client_rsa_private_pkcs8.pem
tls.client.keyPassword=client
tls.client.trustCertPath=/home/rocketmq/ssl/ca.crt

## server setting
tls.server.certPath=/home/rocketmq/ssl/server.crt
tls.server.keyPath=/home/rocketmq/ssl/server_rsa_private_pkcs8.pem
tls.server.keyPassword=server
tls.server.trustCertPath=/home/rocketmq/ssl/ca.crt
#server.auth.client
tls.server.need.client.auth=required
```

## 3. Use the SSL config on RocketMQ 
1. Client Side (System Properties)
```
   -Dtls.enable=true 
   -Dtls.client.authServer=true # force verifying server cert
   -Dtls.test.mode.enable=false # not a test mode
   -Dtls.config.file=/home/rocketmq/ssl/ssl.properties 
```
2. Broker Side (System Properties)   
```
   -Dtls.test.mode.enable=false #not a test mode
   -Dtls.config.file=/home/rocketmq/ssl/ssl.properties 
   -Dtls.server.need.client.auth=required
```


## 4. Appendix

1. It's a bug in Java: https://bugs.openjdk.java.net/browse/JDK-8076999
```
$ docker logs rmqbroker
java.lang.IllegalArgumentException: Input stream does not contain valid private key.
	at io.netty.handler.ssl.SslContextBuilder.keyManager(SslContextBuilder.java:278)
	at org.apache.rocketmq.remoting.netty.TlsHelper.buildSslContext(TlsHelper.java:124)
	at org.apache.rocketmq.remoting.netty.NettyRemotingClient.<init>(NettyRemotingClient.java:133)
	at org.apache.rocketmq.remoting.netty.NettyRemotingClient.<init>(NettyRemotingClient.java:99)
	at org.apache.rocketmq.broker.out.BrokerOuterAPI.<init>(BrokerOuterAPI.java:74)
	at org.apache.rocketmq.broker.out.BrokerOuterAPI.<init>(BrokerOuterAPI.java:70)
	at org.apache.rocketmq.broker.BrokerController.<init>(BrokerController.java:189)
	at org.apache.rocketmq.broker.BrokerStartup.createBrokerController(BrokerStartup.java:210)
	at org.apache.rocketmq.broker.BrokerStartup.main(BrokerStartup.java:58)
Caused by: java.io.IOException: ObjectIdentifier() -- data isn't an object ID (tag = 48)
	at sun.security.util.ObjectIdentifier.<init>(ObjectIdentifier.java:257)
	at sun.security.util.DerInputStream.getOID(DerInputStream.java:314)
	at com.sun.crypto.provider.PBES2Parameters.engineInit(PBES2Parameters.java:267)
	at java.security.AlgorithmParameters.init(AlgorithmParameters.java:293)
	at sun.security.x509.AlgorithmId.decodeParams(AlgorithmId.java:132)
	at sun.security.x509.AlgorithmId.<init>(AlgorithmId.java:114)
	at sun.security.x509.AlgorithmId.parse(AlgorithmId.java:372)
	at javax.crypto.EncryptedPrivateKeyInfo.<init>(EncryptedPrivateKeyInfo.java:95)
	at io.netty.handler.ssl.SslContext.generateKeySpec(SslContext.java:907)
	at io.netty.handler.ssl.SslContext.getPrivateKeyFromByteBuffer(SslContext.java:963)
	at io.netty.handler.ssl.SslContext.toPrivateKey(SslContext.java:953)
	at io.netty.handler.ssl.SslContextBuilder.keyManager(SslContextBuilder.java:276)
	... 8 more

For illustration purposes:

openssl genrsa -out private_openssl.pem
openssl pkcs8 -topk8 -v1 PBE-SHA1-RC4-128 -in private_openssl.pem -out private_pkcs8_v1.pem -passout pass:123456
openssl pkcs8 -topk8 -v2 des3 -in private_openssl.pem -out private_pkcs8_v2.pem -passout pass:123456
KSE can open private_pkcs8_v1.pem just fine (that is when running under Java8, things are even worse with Java7), while trying to open private_pkcs8_v2.pem will cause java.io.IOException: ObjectIdentifier() -- data isn't an object ID (tag = 48).

```