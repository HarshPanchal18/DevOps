# REDIS

## Configuration

Grab default configuration from official [site](https://redis.io/docs/latest/operate/oss_and_stack/management/config/).

Put it inside a config-map (i.e. `cm-redis-conf.yml`).

- Authenticate with password. See for `masterauth` and `requirepass`.
- Enable persistency with `appendonly`.
- Specify Database filename (`dbfilename`) if you want to.

## Installation

Create namespace and apply configmap of configuration (i.e. `cm-redis-conf.yml`).

```bash
kubectl create ns redis
```
