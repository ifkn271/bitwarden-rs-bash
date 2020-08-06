
apt-get update
### docker install
curl -fsSL https://get.docker.com | bash -s docker
apt-get install python3 python3-pip
pip3 install -U
pip3 install docker-compose
### bw
mkdir ./bw
cd bw

cat>docker-compose.yml<<EOF
version: "3"
 
services:
  bitwarden:
    image: bitwardenrs/server
    restart: always
    volumes:
      - /data/bw:/data
    environment:
      WEBSOCKET_ENABLED: "true"
      SIGNUPS_ALLOWED: "true"
 
  caddy:
    image: abiosoft/caddy
    restart: always
    volumes:
      - ./Caddyfile:/etc/Caddyfile:ro
      - caddycerts:/root/.caddy
    ports:
      - 80:80
      - 443:443
    environment:
      ACME_AGREE: "true" 
      DOMAIN: "bitwarden.koko.cat"
      EMAIL: "example@gmail.com"
volumes:
  caddycerts:

EOF

cat><<EOF
{$DOMAIN} {
    tls {$EMAIL}
 
    header / {
        Strict-Transport-Security "max-age=31536000;"
        X-XSS-Protection "1; mode=block"
        X-Frame-Options "DENY"
    }
 
    proxy /notifications/hub/negotiate bitwarden:80 {
        transparent
    }
 
    # Notifications redirected to the websockets server
    proxy /notifications/hub bitwarden:3012 {
        websocket
    }
 
    # Proxy the Root directory to Rocket
    proxy / bitwarden:80 {
        transparent
    }
}
EOF
echo "域名自行更换（我懒，不好意思）"
