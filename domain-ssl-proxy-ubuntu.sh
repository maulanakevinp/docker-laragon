#!/bin/bash

# === Looping project ===
for dir in ~/public_html/*; do
    project=$(basename "$dir")
    compose_file=~/public_html/$project/docker-compose.yml

    if [ -f "$compose_file" ]; then
        docker compose -f "$compose_file" config > /tmp/expanded.yml
        port=$(yq '.services | to_entries[] | select(.value.ports) | .value.ports[0].published' /tmp/expanded.yml | sed 's/"//g')

        # === Persiapan Root CA (dibuat sekali saja) ===
        echo "=== Membuat sertifikat untuk $project.test ==="
        cd ./certs
        mkcert $project.test "*.$project.test" localhost 127.0.0.1 ::1
        cd ..

        echo "=== Membuat Nginx config untuk $project.test ==="
        cat > ./nginx/sites-enabled/$project.test.conf <<EOF
server {
    listen 80;
    server_name $project.test;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name $project.test;

    ssl_certificate     /etc/nginx/certs/$project.test+4.pem;
    ssl_certificate_key /etc/nginx/certs/$project.test+4-key.pem;

    location / {
        proxy_pass http://172.17.0.1:$port;
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Real-Port \$remote_port;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header REMOTE-HOST \$remote_addr;
        proxy_connect_timeout 60s;
        proxy_send_timeout 600s;
        proxy_read_timeout 600s;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
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

    else
        echo "⚠️  Tidak ada docker-compose.yml di $project"
    fi
done

# echo "=== Restarting Nginx ==="
# docker restart nginx

echo "=== Selesai! Domain siap pakai dengan SSL ==="
