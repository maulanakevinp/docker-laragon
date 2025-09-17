#!/bin/bash

# === Looping project ===
for dir in ~/public_html/*; do
    if [ -d "$dir/public" ]; then
        project=$(basename "$dir")
        if [ -f "~/public_html/$project/.php-version" ]; then
            php_version=$(cat "~/public_html/$project/.php-version")
        else
            php_version="php82"
        fi

        # === Persiapan Root CA (dibuat sekali saja) ===
        echo "=== Membuat sertifikat untuk $project.test ==="
        cd ./certs
        mkcert $project.test "*.$project.test" localhost 127.0.0.1 ::1
        cd ..

        echo "=== Creating nginx configuration for $project.test ==="
        cat > ./nginx/sites-enabled/$project.test.conf <<EOF
server {
    listen 80;
    server_name $project.test;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name $project.test;
    root /var/www/$project/public;

    ssl_certificate     /etc/nginx/certs/$project.test+4.pem;
    ssl_certificate_key /etc/nginx/certs/$project.test+4-key.pem;

    index index.php index.html index.htm;
    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;
    
    location ~ \.php$ {
        fastcgi_pass $php_version:9000;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

        echo "=== Tambahkan domain ke hosts ==="
        if ! grep -q "$project.test" /etc/hosts; then
            echo "127.0.0.1 $project.test" | sudo tee -a /etc/hosts
        fi

    fi
done

# echo "=== Restarting Nginx ==="
# docker restart nginx

echo "=== Done! Domain is ready to use with SSL ==="
