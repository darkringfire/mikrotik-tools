# Get trusted certificates

/system script
remove [find name=get-certs]
add name=get-certs source={
  :local DNS 9.9.9.9
  :local URLS {
    "LETS-ISRG-Root-X1"="https://letsencrypt.org/certs/isrgrootx1.pem"
    "LETS-R3"="https://letsencrypt.org/certs/lets-encrypt-r3.pem"
    "LETS-ISRG-Root-X2"="https://letsencrypt.org/certs/isrg-root-x2.pem"
    "LETS-E1"="https://letsencrypt.org/certs/lets-encrypt-e1.pem"
    "DigiCert TLS Hybrid ECC SHA384 2020 CA1"="https://cacerts.digicert.com/DigiCertTLSHybridECCSHA3842020CA1-1.crt.pem"
    "DigiCert Global Root CA"="https://cacerts.digicert.com/DigiCertGlobalRootCA.crt.pem"
    "GTS CA 1C3"="https://crt.sh/?d=3233315902"
    "GTS Root R1"="https://crt.sh/?d=3001951960"
    "GlobalSign Root CA"="https://crt.sh/?d=88"
  }
  :foreach NAME,URL in=$URLS do={
    :local FILE $URL
    :local HOST $URL
    :while ([:find $FILE "/"] >= 0) do={
      :set FILE [:pick $FILE ([:find $FILE "/"]+1) [:len $FILE]]
    }
    :local HOSTBEGIN ([:find $HOST "://"]+3)
    :set HOST [:pick $HOST $HOSTBEGIN [:find $HOST "/" $HOSTBEGIN]]
    :resolve $HOST server=$DNS

    /tool fetch "$URL" dst-path=$FILE
    :local WAIT 100
    :do {
      :delay 100ms
      :set WAIT ($WAIT-1)
    } while=([:len [/file find name=$FILE]]=0 and $WAIT>0)

    /certificate import file-name=$FILE passphrase="" name=$NAME
    /file remove [find name=$FILE]
  }
}
