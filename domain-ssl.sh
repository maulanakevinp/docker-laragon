for dir in /home/ictui/public_html/*; do
  if [ -d "$dir" ]; then
    project=$(basename "$dir")
    if [ -f "/home/ictui/public_html/$project/.php-version" ]; then
        php_version=$(cat "/home/ictui/public_html/$project/.php-version")
    else
        php_version="php82"
    fi
    echo "=== Creating nginx configuration for $project.test ==="
    echo 'server{
        listen 80;
        server_name '$project'.test;
        return 301 https://$host$request_uri;
    }

    server {
        listen 443 ssl;
        server_name '$project'.test;
        root /var/www/'$project'/public;

        ssl_certificate     /etc/nginx/certs/'$project'.test.crt;
        ssl_certificate_key /etc/nginx/certs/'$project'.test.key;

        index index.php index.html index.htm;
        charset utf-8;

        location / {
            try_files $uri $uri/ /index.php?$query_string;
        }

        location = /favicon.ico { access_log off; log_not_found off; }
        location = /robots.txt  { access_log off; log_not_found off; }

        error_page 404 /index.php;
        
        location ~ \.php$ {
            fastcgi_pass '$php_version':9000;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
        }

        location ~ /\.ht {
            deny all;
        }
    }' | tee ./nginx/sites-enabled/$project.test.conf

    echo "=== Creating SSL certificate for $project.test ==="
    
    # Generate private key & certificate
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
    -keyout "./certs/$project.test.key" \
    -out "./certs/$project.test.crt" \
    -subj "/C=ID/ST=JawaBarat/L=Depok/O=LocalDev/OU=IT/CN=$project.test" \
    -addext "subjectAltName=DNS:$project.test"

    echo "=== Adding domain to Windows hosts ==="
    powershell.exe -ExecutionPolicy Bypass -File add-domain.ps1 -Domain $project.test

    echo "=== Importing certificate to Windows Trusted Root ==="
    powershell.exe -Command "Start-Process powershell -Verb RunAs -ArgumentList 'Import-Certificate -FilePath \"$(wslpath -w "./certs/$project.test.crt")\" -CertStoreLocation Cert:\\LocalMachine\\Root'"
  fi
done

echo "=== Restarting Nginx ==="
docker restart nginx

echo "=== Done! Domain is ready to use with SSL ==="
