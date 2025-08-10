#!/bin/bash
echo -n "domain (ex: sso.test): "
read domain
if [ "$domain" == "" ]; then
  echo "Domain cannot be empty"
  exit 1
fi
echo -n "do you want to use proxy (y/n): "
read use_proxy
if [ "$use_proxy" == "y" ]; then
  echo -n "proxy url (ex: http://host.docker.internal:8101): "
  read proxy_url
  if [ "$proxy_url" == "" ]; then
    echo "Proxy URL cannot be empty"
    exit 1
  fi
  echo "=== Membuat konfigurasi Nginx untuk $domain ==="
  mkdir -p ./nginx/sites-enabled
  echo 'server{
    listen 80;
    server_name '$domain';
    return 301 https://$host$request_uri;
  }

  server {
    listen 443 ssl;
    server_name '$domain';

    ssl_certificate     /etc/nginx/certs/'$domain'.crt;
    ssl_certificate_key /etc/nginx/certs/'$domain'.key;

    location ^~ / {
      proxy_pass '$proxy_url';
      proxy_set_header Host $http_host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Real-Port $remote_port;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header REMOTE-HOST $remote_addr;
      proxy_connect_timeout 60s;
      proxy_send_timeout 600s;
      proxy_read_timeout 600s;
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
      proxy_set_header X-Forwarded-Proto https;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
    
    location ~ /\.ht {
      deny all;
    }
  }
  ' | tee ./nginx/sites-enabled/$domain.conf
else
  echo -n "root directory (ex: /var/www/sso/public): "
  read root
    if [ "$root" == "" ]; then
        echo "Root directory cannot be empty"
        exit 1
    fi
  echo -n "php version (ex: 80/81/82) :"
  read php_version
  if [ "$php_version" == "" ]; then
      echo "PHP version cannot be empty"
      exit 1
  fi
  echo "=== Membuat konfigurasi Nginx untuk $domain ==="
  mkdir -p ./nginx/sites-enabled
  echo 'server{
      listen 80;
      server_name '$domain';
      return 301 https://$host$request_uri;
  }

  server {
      listen 443 ssl;
      server_name '$domain';
      root '$root';

      ssl_certificate     /etc/nginx/certs/'$domain'.crt;
      ssl_certificate_key /etc/nginx/certs/'$domain'.key;

      index index.php index.html index.htm;
      charset utf-8;

      location / {
          try_files $uri $uri/ /index.php?$query_string;
      }

      location = /favicon.ico { access_log off; log_not_found off; }
      location = /robots.txt  { access_log off; log_not_found off; }

      error_page 404 /index.php;
      
      location ~ \.php$ {
          fastcgi_pass php'$php_version':9000;
          fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
          include fastcgi_params;
      }

      location ~ /\.ht {
          deny all;
      }
  }' | tee ./nginx/sites-enabled/$domain.conf
fi

echo "=== Membuat sertifikat SSL untuk $domain ==="
mkdir -p ./certs

# Generate private key & certificate
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout "./certs/$domain.key" \
  -out "./certs/$domain.crt" \
  -subj "/C=ID/ST=JawaBarat/L=Depok/O=LocalDev/OU=IT/CN=$domain" \
  -addext "subjectAltName=DNS:$domain"
  
echo "=== Menambahkan domain ke Windows hosts ==="
powershell.exe -Command "Start-Process powershell -Verb RunAs -ArgumentList 'Add-Content -Path \"C:\\Windows\\System32\\drivers\\etc\\hosts\" -Value \"``r``n127.0.0.1 $domain\"'"

echo "=== Mengimpor sertifikat ke Trusted Root Windows ==="
powershell.exe -Command "Start-Process powershell -Verb RunAs -ArgumentList 'Import-Certificate -FilePath \"$(wslpath -w "./certs/$domain.crt")\" -CertStoreLocation Cert:\\LocalMachine\\Root'"

echo "=== Selesai! Domain $domain siap digunakan dengan SSL ==="

docker restart nginx