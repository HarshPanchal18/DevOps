
# The Docker File system

Docker containers run the software stack defined within an [Docker image](https://www.baeldung.com/docker-images-vs-containers). Images are made of a set of read-only layers that work on a filesystem called the Union Filesystem. When we start a new container, Docker adds a read-write [layer on top](https://www.baeldung.com/ops/dive-container-diff#docker-container-image) of the image layers enabling the container to run as if it’s on a standard Linux [filesystem](https://www.baeldung.com/ops/docker-container-filesystem).

So, any file change inside the container creates a working copy in the read-write layer. However, **when the container is stopped or deleted, that read-write layer is lost**:

![[DockerFSImage.png]]

We can verify this by running a command that writes and then reads a file:

```bash
$ docker run bash:latest \
  bash -c "echo hello > file.txt && cat file.txt"
```

The result is:

```text
hello
```

However, if we run the same image with just the command to output the contents of the same file, we get an error:

```bash
$ docker run bash:latest bash -c "cat file.txt"
cat: can't open 'file.txt': No such file or directory
```

## Troubleshooting

* Permission denied while trying to connect to the docker daemon socket at unix://var/run/docker.sock
* Allow current user via appending into docker group.

```bash
sudo usermod -aG docker $USER && newgrp docker
```

## Advanced Commands

While commands like docker run or docker build are staples in a DevOps engineer’s toolkit, Docker offers a wealth of lesser-known commands and features that can unlock advanced functionality, streamline workflows, and address niche use cases.

### 1. docker system df: Analyse Disk Usage in Detail

The Docker system df command provides a comprehensive breakdown of disk space used by Docker objects, including images, containers, volumes, and build cache. It’s a critical tool for resource management.

```bash
docker system df
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          10        4         1.809GB   565.5MB (31%)
Containers      14        3         1.279GB   0B (0%)
Local Volumes   443       3         18.99GB   6.753GB (35%)
Build Cache     121       0         839.8MB   839.8MB
```

Use Case: On a server with limited disk space, use `docker system df -v` to identify which images or dangling volumes are consuming the most space. Combine with docker system prune to reclaim space selectively.

### 2. docker inspect: Deep Dive into Object Metadata

The docker inspect command retrieves low-level JSON metadata for Docker objects (containers, images, networks, volumes), exposing details like configurations, network settings, and runtime state.

```bash
docker inspect [OPTIONS] NAME|ID [NAME|ID...]
```

Use Case: When debugging a container that’s failing to connect to a database, use docker inspect my-container to extract the container’s IP address (NetworkSettings.IPAddress) or environment variables (Config.Env) to verify configurations.

### 3. docker history: Trace Image Layer History

The docker history command displays the layer history of a Docker image, showing the commands and sizes of each layer.

```bash
docker history --no-trunc --human nginx:alpine
```

Use Case: When optimising a custom Docker image, use docker history to identify bloated layers, such as those caused by apt-get install commands that don't clean up cache. This helps you pinpoint inefficiencies and rewrite your Dockerfile using multi-stage builds or cleaner instructions to reduce image size, improve pull speed, and enhance CI/CD performance.

### 4. docker export: Export Container Filesystem

The docker export command exports a container’s filesystem as a tar archive, excluding metadata like image history.

```bash
docker export -o my-container.tar my-container
cat my-container.tar | docker import - my-new-image:latest
```

Use Case: In an air-gapped or protected environment, use docker export to extract a container’s entire filesystem as a tar archive, allowing you to modify the contents offline. You can then repackage it into a new image using docker import, enabling custom deployments without relying on external registries or Dockerfiles, ideal for secure or isolated systems.

### 5. docker events — Monitor Docker Activity

The Docker events command streams real-time events from the Docker daemon, such as container starts, stops, or image pulls.

```bash
docker events --filter 'type=container' --filter 'event=start' --since '2025-05-04' --format '{{.Time}} {{.Type}} {{.Actor.Attributes.name}} {{.Action}}' | \
awk 'BEGIN { printf "%-25s %-10s %-30s %-10s\n", "TIME", "TYPE", "CONTAINER", "ACTION"; print "--------------------------------------------------------------------------------------------"; }
     { printf "%-25s %-10s %-30s %-10s\n", $1, $2, $3, $4 }'
```

Use Case: Integrate docker events with a logging pipeline like the ELK Stack to monitor real-time container lifecycle events in a production Kubernetes cluster. This helps track starts, stops, crashes, and other state changes. Customise the output using the --format flag for easier parsing and integration, enabling proactive alerting and better observability.

### 6. docker top: View Container Processes

The Docker top command displays running processes inside a container, similar to Linux top.

```bash
docker top my-container aux
```

Use Case: When a container is consuming excessive CPU, you can use docker top to quickly identify the culprit process without needing to exec into the container. While docker exec is more commonly used for in-depth process inspection, docker top offers a faster, safer alternative for a high-level view. For a complete picture of resource usage, including CPU, memory, and network I/O, combine this with docker stats to monitor container performance in real-time.

### 7. docker diff: Inspect Container Filesystem Changes

Since it started, the Docker diff command lists filesystem changes (added, modified, deleted) in a container.

```bash
docker diff my-container
```

Legend: A = Added, C = Changed, D = Deleted

Use Case: In a compliance audit, use docker diff to verify that a container's filesystem hasn't been modified unexpectedly during runtime. This helps detect unauthorised changes such as new binaries, tampered configs, or deleted critical files, offering a lightweight method to validate container integrity without needing intrusive scans. It's a niche but powerful tool, often used for debugging, post-incident reviews, or security assessments. For better traceability or offline inspection, redirect the output to a file: docker diff my-container > changes.txt.

### 8. docker trust: Manage Image Signing

The Docker trust command enables content trust to verify image authenticity and integrity using Notary-based signing.

```bash
docker trust inspect nginx:latest
```

Use Case: In a healthcare application, use docker trust to ensure that only cryptographically signed images from a trusted registry are deployed, safeguarding sensitive patient data and meeting compliance standards like HIPAA. This prevents the risk of unverified or malicious images being pulled into production, reinforcing security in highly regulated environments.

### 9. docker manifest: Manage Multi-Architecture Images

The Docker manifest command (experimental in some versions) manages multi-architecture images, supporting platforms like AMD64, ARM, etc.

```bash
docker manifest inspect --verbose nginx:latest
```

Use Case: In a hybrid cloud-edge deployment, use docker manifest to verify that a container image supports both AMD64 for cloud servers and ARM64 for edge devices, ensuring seamless operation across architectures. This is especially useful when building applications that need to run consistently in both data centres and on lightweight edge hardware.
Reference: docker manifest

### 11. docker stats: Monitor Container Resource Usage

The Docker stats command provides real-time resource usage (CPU, memory, network, I/O) for running containers.

```bash
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" my-container
```

Use Case: During performance tuning, use docker stats to monitor real-time resource usage and identify containers that are exceeding memory or CPU limits. This built-in command helps fine-tune resource constraints without needing third-party tools. While it's less common in production setups due to the adoption of external observability stacks like Prometheus or Datadog, it's a quick and handy option for local debugging or lightweight environments.

### 12. docker volume inspect: Examine Volume Details

The Docker volume inspect command provides metadata about a Docker volume, such as its mount point and driver.

```bash
docker volume inspect my-volume
```

Use Case: During volume-related failures, use docker volume inspect to verify the mount point and configuration details of a named volume. This is especially useful when a container can't read from or write to a volume, often caused by permission issues or incorrect paths. While rarely used directly, since most volumes are managed implicitly via docker run or Docker Compose, it's invaluable for debugging.

### 13. docker buildx: Advanced Image Building

The Docker buildx command extends docker build with features like multi-architecture builds, caching, and remote builders.

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t my-app:latest --push .
```

Use Case: In a microservices deployment spanning both cloud and edge, use docker buildx to build multi-architecture images that run seamlessly on x86 cloud servers and ARM-based edge devices. This approach ensures consistent behaviour across environments without maintaining separate images. Though powerful, it's still underused due to its newer tooling and additional setup requirements. To get started, initialise a Buildx builder docker buildx create --use and build with --platform linux/amd64,linux/arm64 for broad compatibility.
