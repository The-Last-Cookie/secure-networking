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
openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -nodes -days 3650 -keyout homelabCA.key -out homelabCA.crt -subj "/C=US/O=My Homelab CA/CN=MyHomelabCA"
```

- `x509`: Generates a self-signed certificate (for a CA).
- `newkey ec`: Creates a new EC key.
- `pkeyopt ec_paramgen_curve:prime256v1`: Uses P-256 curve.
- `nodes`: Skips password protection (optional).
- `-days 3650`: Valid for 10 years.
- `keyout homelabCA.key`: Saves the private key.
- `out homelabCA.crt`: Saves the self-signed CA certificate.
- `subj`: Provides the Distinguished Name (DN)
  - `C=US`: Country
  - `O=My Homelab CA`: Organization (CA)
  - `CN=MyHomelabCA`: Common Name (CA)

The **CA key** (homelabCA.key) and **CA certificate** (homelabCA.crt) are now ready to be used to sign server certificates.

### Create a Certificate Configuration File (`cert.cnf`)

Template:

```sh
# Country Name (C)
#Organization Name (O)
#Common Name (CN) - Set this to your server’s hostname or IP address.

# SAN (Subject Alternative Name), [alt-names] is required
# You can add as many hostname and IP entries as you wish

[req]
default_md = sha256
distinguished_name = req_distinguished_name
req_extensions = v3_ext
x509_extensions = v3_ext
prompt = no

[req_distinguished_name]
C = US
O = My Homelab
CN = pi.hole

[v3_ext]
subjectAltName = @alt_names

# TODO: Add key usage extension

[alt_names]
DNS.1 = pi.hole                 # Default pihole hostname
DNS.2 = pihole-test             # Replace with your server's hostname
DNS.3 = pihole-test.home.arpa   # Replace with your server's FQDN
IP.1 = 10.10.10.115             # Replace with your Pi-hole IP
IP.2 = 10.10.10.116             # Another local IP if needed
```

### Generate a Key and CSR

Use Elliptic Curve Digital Signature Algorithm (ECDSA) to generate both the private key (`tls.key`) and Certificate Signing Request (CSR) (`tls.csr`).

```sh
openssl req -new -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -nodes -keyout tls.key -out tls.csr -config cert.cnf
```

- `-newkey ec`: Creates a new EC key.
- `-pkeyopt ec_paramgen_curve:prime256v1`: Uses P-256 curve.
- `-nodes` - No password on the private key.
- `-keyout tls.key`: Saves the private key.
- `-out tls.csr`: Saves the certificate signing request (CSR).
- `-config cert.cnf`: Uses the config file for CSR details.

### Sign the CSR with the CA

This generates your server certificate from the CSR.

```sh
openssl x509 -req -in tls.csr -CA homelabCA.crt -CAkey homelabCA.key -CAcreateserial -out tls.crt -days 365 -sha256 -extfile cert.cnf -extensions v3_ext
```

- `-req -in tls.csr`: Uses the Certificate Signing Request (CSR) for signing.
- `-CA homelabCA.crt -CAkey homelabCA.key`: Uses our CA to sign the certificate.
- `-CAcreateserial`:Generates a unique serial number.
- `-out tls.crt`: Saves the signed certificate.
- `-days 365`: Valid for 365 days (1 year).
- `-extfile cert.cnf` -extensions v3_ext → Includes Subject Alternative Names (SAN)s.

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

TODO

- <https://gist.github.com/kaczmar2/e1b5eb635c1a1e792faf36508c5698ee>
- <https://arminreiter.com/2022/01/create-your-own-certificate-authority-ca-using-openssl/>
- <https://youtu.be/bv47DR_A0hw>
- <https://www.golinuxcloud.com/create-certificate-authority-root-ca-linux/>
- <https://superuser.com/questions/738612/openssl-ca-keyusage-extension>
- <https://docs.pi-hole.net/api/tls/>

## Annotations

[^schutzziele]: "Schutzziele": [Motivation und Ziele der Informationssicherheit](https://de.wikipedia.org/wiki/Informationssicherheit#Motivation_und_Ziele_der_Informationssicherheit)
[^naming-scheme]: A more detailed explanation on the naming scheme can be found in [Cipher suite § Naming scheme](https://en.wikipedia.org/wiki/Cipher_suite#Naming_scheme)
[^key-exchange]: Examples of this include the Diffie-Hellman-Exchange or the encryption of the symmetric key with a public/private key pair.
