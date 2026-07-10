# Dockback - reverse-engineers an approximate Dockerfile from any Docker image. No external dependencies, pure Bash + Docker CLI

## Install

```bash
curl -fsSL https://repo.guztia.com/install-dockback.sh | bash
```

---

## Overview

Generate a Dockerfile from `httpd:alpine`

```bash
dockback -p httpd:alpine
```

## References

- [albertoroura](https://albertoroura.com/dockback-reverse-engineering-dockerfiles-from-images/)
