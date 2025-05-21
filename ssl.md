# Secure Socket Layer (SSL)

**Transport Layer Security** (TLS), formerly **Secure Socket Layer** (SSL), is used to encrypt the data which is transported over an insecure channel, as well as that the data can not be tampered with.

To create a connection over SSL, certificates need to be exchanged and verified (from one endpoint or both). Certificates ensure that the connection is secure and can not be manipulated by a third party.[^schutzziele] For this, a cipher suite[^naming-scheme] is negotiated which usually contains

- a key exchange algorithm: the symmetric key for encryption is transmitted to the other endpoint via an exchange[^key-exchange]
- an encryption algorithm: the actual data is being encrypted so no malicious actor is able to view the data (confidentiality)
- a message authentication code (MAC): this ensures that the data being sent is not altered by a malicious actor via hash validation (digital signing)

## Method 1: Create your own Certificate Authority (CA)

By default, Pi-hole provides a self-signed SSL certificate, but you can create your own self-signed certificate that specifies your desired hostname, the fully qualified domain name (FQDN), and the IP address for your Pi-hole server using **OpenSSL**.

The advantage in setting up your own CA is that you can sign certificates for each server and install only one CA certificate (e.g. in your browser) instead of trusting multiple self-signed certificates.

Certificates must be in PEM format containing both the private key and certificate.

If not already present, install OpenSSL:

```sh
sudo apt install openssl
```

Create a folder to hold your certificate, config, and key files:

```sh
mkdir -p ~/crt && cd ~/crt
```

### Create a Certificate Authority (CA) Key and Certificate

```sh
openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -noenc -days 3650 -keyout homelabCA.key -out homelabCA.crt -subj "/C=US/O=My Homelab CA/CN=MyHomelabCA"
```

- `-x509`: Generates a self-signed certificate (for a CA).
- `-newkey ec`: Creates a new EC key.
- `-pkeyopt ec_paramgen_curve:prime256v1`: Uses P-256 curve.[^p-256]
- `-noenc`: Skips password protection (optional).
- `-days 3650`: Valid for 10 years.
- `-keyout homelabCA.key`: Saves the private key.
- `-out homelabCA.crt`: Saves the self-signed CA certificate.
- `-subj`: Provides the Distinguished Name (DN)
  - `C=US`: Country
  - `O=My Homelab CA`: Organization (CA)
  - `CN=MyHomelabCA`: Common Name (CA)

The **CA key** (homelabCA.key) and **CA certificate** (homelabCA.crt) are now ready to be used to sign server certificates.

### Create a Certificate Configuration File (`cert.cnf`)

See the [certificate template](#certificate-template).

### Generate a Key and CSR

Use Elliptic Curve Digital Signature Algorithm (ECDSA) to generate both the private key (`tls.key`) and Certificate Signing Request (CSR) (`tls.csr`).

```sh
openssl req -new -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -noenc -keyout tls.key -out tls.csr -config cert.cnf
```

- `-newkey ec`: Creates a new EC key.
- `-pkeyopt ec_paramgen_curve:prime256v1`: Uses P-256 curve.
- `-noenc` - No password on the private key.
- `-keyout tls.key`: Saves the private key.
- `-out tls.csr`: Saves the certificate signing request (CSR).
- `-config cert.cnf`: Uses the config file for CSR details.

### Sign the CSR with the CA

This generates your server certificate from the CSR.

```sh
openssl x509 -req -in tls.csr -CA homelabCA.crt -CAkey homelabCA.key -CAcreateserial -out tls.crt -days 365 -sha256 -extfile cert.cnf -extensions v3_req
```

- `-req -in tls.csr`: Uses the Certificate Signing Request (CSR) for signing.
- `-CA homelabCA.crt -CAkey homelabCA.key`: Uses our CA to sign the certificate.
- `-CAcreateserial`:Generates a unique serial number.
- `-out tls.crt`: Saves the signed certificate.
- `-days 365`: Valid for 365 days (1 year).
- `-extfile cert.cnf` -extensions v3_req → Includes Subject Alternative Names (SAN)s.

### Create a combined tls.pem File

```sh
cat tls.key tls.crt | tee tls.pem
```

On the Pi-hole server, remove now the existing self-signed certificate files and copy your own `tls.pem` combined certificate to the Pi-hole directory:

```sh
sudo rm /etc/pihole/tls*

sudo cp tls.pem /etc/pihole
```

Pi-hole has by default two certificate files, the root CA certificate is in `/etc/pihole/tls_ca.crt`, and the server certificate in `/etc/pihole/tls.pem`.

### Restart Pi-hole

```sh
sudo service pihole-FTL restart
```

### Add the CA to the Trusted Root Certificate Store

Install the root certificate into your browser, so that server certificates signed by this CA will be marked as verified.

<!-- installing cert in browser or os root store -> mmc.exe -->

### Issuing additional server certificates with your CA (Optional)

Now, the created CA can be used to sign new certificates. If the root CA is stored in the browser, these certificates will automatically be recognised as valid.

```sh
# New certificate signing request
openssl req -new -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -noenc -keyout tls2.key -out tls2.csr -config cert2.cnf

# Sign the new certificate
openssl x509 -req -in tls.csr -CA homelabCA.crt -CAkey homelabCA.key -CAcreateserial -out tls2.crt -days 365 -sha256 -extfile cert2.cnf -extensions v3_req
```

## Method 2: Use a self-signed certificate and manually trust it

This method is simpler than setting up a CA, however, each self-signed certificate must be installed and trusted manually.

### Create a directory to hold your cert, config, and key files

```sh
mkdir -p ~/crt && cd ~/crt
```

### Create a Certificate Configuration File (`cert.cnf`)

See the [certificate template](#certificate-template).

### Generate a key and self-signed certificate

Use **Elliptic Curve Digital Signature Algorithm (ECDSA)** to generate both the **private key** (`tls.key`) and the **Self-Signed Certificate** (`tls.crt`).

```sh
openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -noenc -days 365 -keyout tls.key -out tls.crt -config cert.cnf
```

- `x509`: Creates a self-signed certificate.
- `-newkey ec`: Creates a new Elliptic Curve (EC) key.
- `-pkeyopt ec_paramgen_curve:prime256v1`: Uses P-256 (NIST prime256v1) curve.
- `-noenc`: Skips password protection.
- `-days 365`: Valid for 365 days (1 year).
- `-keyout tls.key`: Saves the private key.
- `-out tls.crt`: Saves the self-signed certificate.
- `-config cert.cnf` Uses cert configuration file `cert.cnf` defined above.

### Create a combined tls.pem File

```sh
cat tls.key tls.crt | tee tls.pem
```

On the Pi-hole server, remove now the existing self-signed certificate files and copy your own `tls.pem` combined certificate to the Pi-hole directory:

```sh
sudo rm /etc/pihole/tls*

sudo cp tls.pem /etc/pihole
```

Pi-hole has by default two certificate files, the root CA certificate is in `/etc/pihole/tls_ca.crt`, and the server certificate in `/etc/pihole/tls.pem`.

### Restart Pi-hole

```sh
sudo service pihole-FTL restart
```

### Install self-signed certificate

<!-- installing cert in browser or os root store -> mmc.exe -->

## Certificate template

Save as `cert.cnf`.

```sh
# Country Name (C)
# Organization Name (O)
# Common Name (CN) - Set this to your server’s hostname or IP address.

# SAN (Subject Alternative Name), [alt-names] is required
# You can add as many hostname and IP entries as you wish

[req]
default_md = sha256
distinguished_name = req_distinguished_name
req_extensions = v3_req
x509_extensions = v3_ca
prompt = no

[req_distinguished_name]
C = US
O = My Homelab
CN = pi.hole

# Used for self-signed certificates
[v3_ca]
subjectAltName = @alt_names
keyUsage = keyCertSign

# Used for certificate signing requests
[v3_req]
subjectAltName = @alt_names
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment, keyAgreement
extendedKeyUsage = serverAuth

[alt_names]
DNS.1 = pi.hole                 # Default pihole hostname
DNS.2 = pihole-test             # Replace with your server's hostname
DNS.3 = pihole-test.home.arpa   # Replace with your server's FQDN
IP.1 = 10.10.10.115             # Replace with your Pi-hole IP
```

## Links

*TODO: Integrate these in the document.*

General workflow:

- [Lockdown the unencrypted key file via permissions (filesystem ACL)](https://stackoverflow.com/a/23718323)
- [How can I generate a self-signed SSL certificate using OpenSSL?](https://stackoverflow.com/questions/10175812/how-can-i-generate-a-self-signed-ssl-certificate-using-openssl) (several answers with useful input, especially about the parameters to set in the config file)
- <https://arminreiter.com/2022/01/create-your-own-certificate-authority-ca-using-openssl/>
- <https://youtu.be/bv47DR_A0hw>
- <https://www.golinuxcloud.com/create-certificate-authority-root-ca-linux/>
- <https://docs.pi-hole.net/api/tls/>

Creation of the config file:

- [Official example for a config file](https://github.com/openssl/openssl/blob/master/apps/openssl.cnf)
- [openssl docs](https://docs.openssl.org/master/man5/x509v3_config/#standard-extensions)
- [KeyUsage extension](https://superuser.com/questions/738612/openssl-ca-keyusage-extension)
- [Minimal cert config file](https://technotes.shemyak.com/posts/min-openssl-cnf/)
- [Example for a config file](https://github.com/JW0914/Wikis/blob/master/Scripts%2BConfigs/OpenSSL/openssl.cnf)

<!--
openssl x509 -in mycert.pem -text -noout
-->

## References

- This project was inspired by ["Pi-hole v6: Creating Your Own Self-Signed SSL Certificates" by kaczmar2 (2025-02-22)](https://gist.github.com/kaczmar2/e1b5eb635c1a1e792faf36508c5698ee)

## Annotations

[^schutzziele]: "Schutzziele": [Motivation und Ziele der Informationssicherheit](https://de.wikipedia.org/wiki/Informationssicherheit#Motivation_und_Ziele_der_Informationssicherheit)
[^naming-scheme]: A more detailed explanation on the naming scheme can be found in [Cipher suite § Naming scheme](https://en.wikipedia.org/wiki/Cipher_suite#Naming_scheme)
[^key-exchange]: Examples of this include the Diffie-Hellman-Exchange or the encryption of the symmetric key with a public/private key pair.
[^p-256]: P-256 and P-384 are two of the most widely supported key algorithms as of 2025.
