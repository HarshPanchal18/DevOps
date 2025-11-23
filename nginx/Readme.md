# NGINX webserver

## Nginx Configuration

- [Reference](nginx.org/docs/dirindex.html)

The main config file is typically named **nginx.conf** located in the `/etc/nginx/` folder.

- Simple config:

```conf
server {
    listen 80;
    server_name example.com www.example.com;

    location / { # location - defines how the server should process specific types of requests
        root /var/www/example.com;
        index index.html index.htm;
    }
}
```

- Forward traffic to other web server:

```conf
server {
    listen 80;
    server_name example.com www.example.com;

    location / {
        proxy_pass http://backend_server_address;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

- Configure load balancing (default: **Round Robin**)

```conf
http {
    upstream myapp1 {
        # Three instances of the same app
        server srv1.example.com;
        server srv2.example.com;
        server srv3.example.com;
    }

    # All requests are proxied to the server group myapp1
    server {
        listen 80;

        location / {
            proxy_pass http://myapp1;
        }
    }
}
```

- Enable the caching

```conf
http {
    # ...

    proxy_cache_path /data/nginx/cache key_zone=mycache:10m;
    server {

        location / {
            proxy_pass http://myapp1;
        }
    }
}
```
