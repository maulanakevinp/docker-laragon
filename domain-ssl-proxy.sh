for dir in /home/ictui/public_html/*; do
  if [ -d "$dir" ]; then
    project=$(basename "$dir")
    compose_file="/home/ictui/public_html/$project/docker-compose.yml"
    if [ -f "$compose_file" ]; then
        docker-compose -f "$compose_file" config > /tmp/expanded.yml
        port=$(yq '.services | to_entries[] | select(.value.ports) | .value.ports[0].published' /tmp/expanded.yml | sed 's/"//g')
        echo "=== Creating nginx configuration for $project.test ==="
        echo 'server{
    listen 80;
    server_name '$project'.test;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name '$project'.test;

    ssl_certificate     /etc/nginx/certs/'$project'.test.crt;
    ssl_certificate_key /etc/nginx/certs/'$project'.test.key;

    location ^~ / {
    proxy_pass http://host.docker.internal:'$port';
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
  fi
done

echo "=== Restarting Nginx ==="
docker restart nginx

echo "=== Done! Domain is ready to use with SSL ==="
