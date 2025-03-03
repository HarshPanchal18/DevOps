# Docker Compose

```yaml
services:
    db:
        image: postgres:16

        environment:
            POSTGRES_USER: ${POSTGRES_USER}
            POSTGRES_PASSWORD: ${POSTGRES_PASSWD}

        volumes:
            - pgdata:/var/lib/postgresql/data

        healthcheck:
            test:
                - "CMD-SHELL"
                - "pg_isready -U cpow"

            interval: 10s
            timeout: 5s
            retires: 5

    web:
        build: . # Path of Dockerfile
        command: bash -c "rm -f /tmp/pids/server.pid && bundle exec rails s -b '0.0.0.0'"
        volumes:
            - .:/rails
        ports:
            - 3000:3000
        depends_on:
            db:
                condition: service_healthy
        environment:
            DATABASE_HOST: ${DATABASE_HOST}
            DATABASE_USER: ${DATABASE_USER}
            DATABASE_PASSWORD: ${DATABASE_PASSWORD}

volumes:
    pgdata:
```

## Under the hood

```mermaid
graph LR

    A(Web)-->B(DNS)--db:5432-->D(DB)

```
