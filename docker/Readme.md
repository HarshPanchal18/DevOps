# Docker

## The Docker File system

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
sudo chmod 666 /var/run/docker.sock
```

---

Creating cluster "kind" ... ✓ Ensuring node image (kindest/node:v1.33.1) 🖼 ✓ Preparing nodes 📦 📦 📦 ✓ Writing configuration 📜 ✓ Starting control-plane 🕹️ ✓ Installing StorageClass 💾 ✗ Joining worker nodes 🚜 Deleted nodes: ["kind-worker" "kind-worker2" "kind-control-plane"] ERROR: failed to create cluster: failed to join node with kubeadm: command "docker exec --privileged kind-worker kubeadm join --config /kind/kubeadm.conf --v=6" failed with error: exit status 1 Command Output: I1117 06:01:28.522034 173 join.go:421] [preflight] found NodeName empty; using OS hostname as NodeName

This error usually happens when **worker nodes fail the kubeadm preflight checks** during `kind` cluster creation. The last log line shows:

```bash
[preflight] found NodeName empty; using OS hostname as NodeName
```

...but the creation *still* failed. The two most common causes:

---

### System has not been booted with systemd as init system (PID 1). Can't operate. Failed to connect to bus: Host is down

[Reference](https://askubuntu.com/questions/1379425/system-has-not-been-booted-with-systemd-as-init-system-pid-1-cant-operate)

```bash
$ sudo systemctl start docker
System has not been booted with systemd as init system (PID 1). Can't operate.
Failed to connect to bus: Host is down
```

```bash
sudo -e /etc/wsl.conf
```

Add the following

```conf
[boot]
systemd=true
```

Exit ubuntu and again

```bash
wsl --shutdown
```

Then restart Ubuntu

```bash
sudo systemctl status
```

### Permission denied while trying to connect to the docker API

```bash
$ docker images
permission denied while trying to connect to the docker API at unix:///var/run/docker.sock
```

Add the current user to the docker group & Change the permissions of docker socket to be able to connect to the docker daemon `/var/run/docker.sock`

```bash
sudo usermod -aG docker $USER
sudo chmod 666 /var/run/docker.sock
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

## Misconfigurations You Should Avoid

1. Running Docker container in rootless mode

    ```Dockerfile
    FROM python:3.10
    RUN pip install flask
    ```

    By default, Docker containers run as the root user, which increases the risk of privilege escalation if the container is compromised. A safer practice is to create and use a non root user inside the container.

    ```Dockerfile
    FROM python:3.10
    RUN pip install flask
    USER normaluser
    ```

2. Using tagged minimal base images and multistage builds

    ```Dockerfile
    FROM python:3.10 as build
    WORKDIR /app
    COPY requirements.txt app.py ./
    RUN pip install -r requirements.txt
    EXPOSE 5000
    CMD ["python", "app.py"]
    ```

    Using large untagged images leads to bloated containers and unpredictable builds. A better approach is to use versioned tags and multistage builds. Here, dependencies are installed in a builder image, and only the required artifacts are copied into a lightweight runtime image.

    ```Dockerfile
    FROM python:3.10 as build
    WORKDIR /app
    COPY requirements.txt app.py ./
    RUN pip install -r requirements.txt
    FROM gcr.io/distroless/python3
    COPY --from=build /app /
    EXPOSE 5000
    CMD ["python", "app.py"]
    ```

3. Using COPY command with specific parameters

    ```Dockerfile
    COPY . .
    ```

    Using a broad `COPY . .` can unintentionally include unnecessary files such as configs, build artifacts, or secrets. It makes images larger and riskier. Instead, copy only the required files or directories explicitly, like `COPY target/app.jar /app`.

    ```Dockerfile
    COPY target/app.jar /app
    ```

4. Update and install packages in the same RUN instruction

    ```Dockerfile
    FROM python:3.10
    RUN pip install --upgrade pip
    RUN pip install flask requests==2.31.*
    ```

    Splitting updates and package installations across multiple RUN layers leads to larger image sizes and cache inconsistencies. Combining them in a single RUN reduces layers, keeps images cleaner, and ensures package versions remain consistent during builds.

    ```Dockerfile
    FROM python:3.10
    RUN pip install --upgrade pip && pip install \
        flask \
        requests==2.31.*
    ```

5. Removing unnecessary dependencies

    ```Dockerfile
    FROM debian:11
    RUN apt-get update && apt-get -y install \
        python3 \
        python3-venv
    ```

    Package managers often install extra packages by default, which makes images larger and more complex. Installing only what is strictly required keeps the image lightweight, improves maintainability, and reduces the potential attack surface.

    ```Dockerfile
    FROM debian:11
    RUN apt-get update && apt-get -y install --no-install-recommends \
        python3 \
        python3-venv
    ```

## Docker Daemon Logs: How to Find, Read, and Use Them

Sometimes Docker behaves in ways that catch you off guard—containers don’t start as expected, images pause during pull, or networking takes longer than usual to respond.

In those moments, the Docker daemon logs are your best reference point.

These logs capture exactly what the Docker engine is doing at any given time. They give you a running account of system state, performance signals, and events that help you understand what’s happening beneath the surface.

### What is the Docker Daemon?

The Docker daemon (dockerd) is the background process that makes Docker work. It listens for API requests and manages things like images, containers, networks, and volumes.

When you run a command such as docker run or docker build, the client talks to the daemon. From there, the daemon pulls images, starts containers, assigns resources, and keeps everything running. Without it, Docker doesn’t function.

#### Why Docker Daemon Logs are Important

Daemon logs are the running account of what Docker is doing. They give you:

* Troubleshooting clues – If a container won’t start or an image pull hangs, logs show where the issue began.
* Performance signals – Spikes or repeated warnings can point to bottlenecks before they cause bigger trouble.
* Security visibility – Image pulls, container creation, and other key actions are logged, giving you an audit trail.
* System health – Startup events, config changes, and runtime details tell you how Docker is behaving over time.
* Compliance coverage – For many teams, keeping these logs isn’t optional — they’re part of the record.
* Daemon logs turn Docker from a black box into something you can observe and reason about.

#### Where to Find Docker Daemon Logs

Finding the Docker daemon logs is the first step in troubleshooting or monitoring Docker. The exact location depends on your OS and how Docker was installed, but there are clear defaults you can rely on.

##### Linux Systems

Most Linux distributions integrate Docker logs with the system’s logging service. Depending on your setup, you’ll either use journalctl (`systemd`) or check traditional log files.

###### Using journalctl (systemd-based distros: Ubuntu, Debian, Fedora, CentOS 7+)

The daemon logs are stored in the systemd journal.

```bash
# Show all daemon logs
journalctl -u docker.service

# Follow logs live (like tail -f)
journalctl -u docker.service -f

# Filter by time
journalctl -u docker.service --since "1 hour ago"
journalctl -u docker.service --since "2023-10-26 10:00:00" --until "2023-10-26 11:00:00"
```

You may need sudo privileges to run these commands.
Using log files (rsyslog or older Linux):
Some older distributions, or custom installs, still write logs directly to files:

```bash
/var/log/docker.log
/var/log/messages (mixed with system logs)
/var/log/syslog (mixed with system logs)
```

Examples:

```bash
sudo tail -f /var/log/docker.log
sudo cat /var/log/syslog | grep dockerd
```

##### Windows Systems

On Windows, Docker integrates with the Event Viewer and Docker Desktop.

* Event Viewer:
  * Open Event Viewer (`eventvwr.msc`)
  * Navigate to Windows Logs → Application
  * Filter by Source (`Docker` or `dockerd`) to see events such as startup, shutdown, or critical errors
* Docker Desktop Diagnostics:
  * Click the Docker icon in the system tray
  * Select Troubleshoot (bug icon) → Get logs
  * This generates a diagnostics bundle that includes daemon logs plus other useful info
* `dockerd.exe` output (development use):

Running `dockerd.exe` directly from a terminal stream logs to the console. Handy for debugging startup issues, but not something you’d rely on in production.

##### macOS Systems

Docker on macOS runs inside a lightweight Linux VM managed by Docker Desktop.

Docker Desktop Diagnostics (recommended):

* Click the Docker whale icon in the macOS menu bar
  * Go to Troubleshoot → Get logs
  * This produces a bundle with daemon logs and other Docker Desktop components
* Accessing the VM directly (advanced):
  * Advanced users can log into the Linux VM created by Docker Desktop and use journalctl from inside. This is rarely needed since the diagnostics tool covers most use cases.

#### A Quick Reference

| Platform        | Default Method                           | Alternative                              |
|-----------------|------------------------------------------|------------------------------------------|
| Linux (systemd) | journalctl -u docker.service             | Time filtering with --since / --until    |
| Linux (older)   | /var/log/docker.log                      | /var/log/messages or /var/log/syslog     |
| Windows         | Event Viewer → Application logs          | Docker Desktop → Troubleshoot → Get logs |
| macOS           | Docker Desktop → Troubleshoot → Get logs | Advanced: VM access with journalctl      |

### How to Read Docker Daemon Logs Effectively

Once you know where the logs are, the next step is learning how to make sense of them. Docker daemon logs can look busy, but with the right approach, you can quickly spot the details that matter.

#### Log Levels: How to Prioritize

Docker logs are grouped by severity. These levels help you decide what to look at first:

* DEBUG – Very detailed output for tracing execution flow. You’ll use this when you need fine-grained insight into how the daemon is operating.
* INFO – Normal events: container start/stop, image pulls, network setup. These show you what’s happening under normal conditions.
* WARN – Signals something isn’t ideal, but Docker is still running. Examples include deprecated configs or resource pressure. These are worth reviewing before they turn into larger issues.
* ERROR – An operation failed, like a container that didn’t start or a registry connection that broke. These require action.
* FATAL – The daemon itself has stopped working. This is rare but critical to address right away.

A good habit is to start with ERROR and FATAL, then review WARN for additional context. Drop into INFO or DEBUG when you need a fuller picture.

## Docker Model Runner

Docker Model Runner (DMR) makes it easy to manage, run, and deploy AI models using Docker.

You can serve models via OpenAI and Ollama-compatible APIs, package GGUF files as OCI Artifacts, and interact with models from both the command line and graphical interface.

### How Docker Model Runner works

Models are pulled from Docker Hub, an OCI-compliant registry, or Hugging Face the first time you use them and are stored locally. They load into memory only at runtime when a request is made, and unload when not in use to optimize resources. Because models can be large, the initial pull may take some time. After that, they're cached locally for faster access.

You can interact with the model using [OpenAI and Ollama-compatible APIs](https://docs.docker.com/ai/model-runner/api-reference/).

### Enable Docker Model Runner

Ubuntu/Debian based:

```bash
sudo apt-get update
sudo apt-get install docker-model-plugin
```

RPM-based

```bash
sudo dnf update
sudo dnf install docker-model-plugin
```

Test installation

```bash
docker model version
docker model run ai/smollm2
```

Pull a model

```bash
# Pull from dockerhub
docker model pull ai/smollm2:360M-Q4_K_M

# Pull from Hugging face
docker model pull hf.co/bartowski/Llama-3.2-1B-Instruct-GGUF
```

Push a model

```bash
# Tag a pulled model under a new name
docker model tag ai/smollm2 myorg/smollm2

# Push it to Docker Hub
docker model push myorg/smollm2
```

## Docker Status Unhealthy

If your container shows `Status: unhealthy`, Docker's health check is failing. The container is still running, but something inside—usually your app—isn't responding as expected.

This doesn't always mean a crash. It just means Docker can't verify the app is working. The health check runs separately from the container's lifecycle, so even a running container can be marked unhealthy if it fails repeated checks.

### How Docker Health Status Work

Docker runs health checks separately from the container's lifecycle. Even if a container is running, Docker can still mark is as `Unhealthy` if the health check command fails.

A health check runs inside the container at set intervals. It typicaslly hits an endpoint or runs a command to check if your app is alive and responding.

There are three possible health states:

* `starting`: The container is still in its startup period.
* `healthy`: The last few health check passed.
* `unhealthy`: Multiple health check failed.

The container's health status depends on the exit code from the command:

* 0: Healthy
* 1: Unhealthy
* Anything else: Inconclusive, Docker leaves the status unchanged.

### Docker Health Checks DIY

1. Check what failed
    Inspect health logs:

    ```bash
    docker inspect --format "{{json .State.Health}}" container-name | jq
    ```

    Look for the recent `Output`, `ExitCode`, and error messages.

2. Test the health check inside containers.
    Match the container's environment:

    ```bash
    docker exec -it container-name sh -c 'YOUR-HEALTH-CHECK-COMMAND'
    ```

    This catches issues with missing permissions, dependencies, or ports.

3. Fix the most common causes

    * App crash: Logs show connection refused or stack traces
    * Missing dependency: DB or API call fails inside the container
    * Slow startup or load: Health check times out repeatedly
    * Wrong health check config: Mismatched port or URL path

4. Adjust the health check settings

    ```dockerfile
    HEALTHCHECK --interval=30s --timeout=10s --start-period=45s --retries=3 \
      curl -f http://localhost:8080/healthz || exit 1
    ```

5. Let Docker restart it
    To enable restarts, Exit the process on failure to trigger the restart policy

    ```dockerfile
    CMD curl -f http://localhost:8080/healthz || kill -s 15 1
    ```

### Inspect health check logs

#### Check the Health Logs

Start by inspecting the container's health details. This helps you see exactly what Docker's health check is doing and why it's failing.

Use this command:

```bash
docker inspect --format "{{json .State.Health }}" container_name
```

Look for ExitCode: `0` (success) or ExitCode: `1` (failure). Any output from the failed checks can help narrow down the issue.

It returns structured output with:

* Current health status (starting, healthy, unhealthy)
* Failing streak count
* A log of recent health checks (with timestamps, exit codes, and output)

#### Debug health check commands

Test your health check command directly inside the container to isolate the issue:

```bash
docker exec -it container_name curl -f http://localhost:8080/health
echo $?
```

This approach lets you see exactly what your health check encounters. You might discover that the health endpoint returns unexpected status codes, takes too long to respond, or that required tools like `curl` aren't available in your container.

If the health check command works when you run it manually but fails in the health check, the difference is usually timing (it's running before your app is ready) or environment (missing env vars, wrong network settings).

#### Use custom health check scripts

If your app needs more than a single HTTP check, write a script:

```dockerfile
COPY healthcheck.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/healthcheck.sh
HEALTHCHECK CMD /usr/local/bin/healthcheck.sh
```

Example healthcheck.sh:

```bash
#!/bin/bash

# Check Postgres
pg_isready -h localhost -p 5432 -U myuser || exit 1

# Check API
curl -f <http://localhost:8080/api/health> || exit 1

# Check Redis
redis-cli ping || exit 1
exit 0
```

Keep the script fast and lightweight. Avoid expensive operations or long-running queries.

#### Write Checks That Reflect Real Application Health

A health check should confirm the app can serve requests, not just that the process exists.

Good examples:

* HTTP services: `curl -f http://localhost:8080/api/health`
* Databases: `pg_isready -h localhost -p 5432 -U myuser`
* Message brokers: `nc -z rabbitmq 5672`

Avoid checks that only confirm the process is alive (e.g., checking `PID` files or running `ps`). Your container can look "healthy" even if the app is broken.

The best health checks hit a real endpoint or connection that exercises the core functionality. If your app serves HTTP requests, check an HTTP endpoint. If it processes queue messages, check the queue connection. Don't check a sidecar process that has nothing to do with your actual service.

### Tune health check parameters

* `interval`: How Often to Run the Check

  This controls how often Docker runs the health check.

  * Set it too low, and your container spends half its time checking itself.
  * Set it too high, and you won't catch failures quickly.

  **Tip**: 10–30 seconds is a good starting point. Go shorter for critical services that need fast detection.

* `timeout`: How Long to Wait for a Response

  If your app takes a while to respond—especially under load—short timeouts can cause false alarms.

  **Tip**: Match this to your app's real response time. If most endpoints return in under a second, 2–5 seconds should be plenty.

* `retries`: How Many Fails Before Giving Up

  Some apps stall occasionally—say, during GC or burst load. One failure doesn't always mean something's wrong.

  **Tip**:
  * Use higher retries (3–5) for apps that sometimes hiccup.
  * Lower retries (1–2) are better if you want to fail fast and restart quickly.

* `start_period`: Grace Time After Startup

  Some apps need a bit to get going—connecting to databases, loading config, etc. Without a grace period, the health check might fail before the app is even ready.

  **Tip**: If your app takes 30 seconds to boot, set a start_period of 30–60 seconds. It'll save you from false starts and restart loops.

## Incidents

### VolumeMounts throw "permission denied" in prod. You can't run as root. How do you fix this issue with UID/GID mapping?

To address "permission denied" errors in production when mounting volumes without running as root, you must align the UID/GID of the application user inside the container with the owner of the files or directories on the host. [stackoverflow](https://stackoverflow.com/questions/24288616/permission-denied-on-accessing-host-directory-in-docker)

#### Preferred Production Strategies

* **Align UID/GID during image build:** Define a specific user and group in your `Dockerfile` with a fixed UID/GID that matches the expected host environment. This is the most robust and secure approach, as it avoids runtime permission changes. [stackoverflow](https://stackoverflow.com/questions/51188997/docker-uid-gid-mapping-changes-on-different-host)

    ```dockerfile
    # Creating a user with a specific UID/GID
    RUN groupadd -g 1001 appgroup && \
        useradd -u 1001 -g appgroup -s /bin/bash appuser
    USER 1001:1001
    ```

* **Entrypoint initialization:** Use an `ENTRYPOINT` script that runs as root during container startup to check and correct the ownership of the mounted volume using `chown`, then switch to the non-root user to start the application (e.g., using `gosu` or `su-exec`). This handles dynamic environments where the host UID/GID might be unknown until runtime. [stackoverflow](https://stackoverflow.com/questions/39397548/how-to-give-non-root-user-in-docker-container-access-to-a-volume-mounted-on-the)

    ```bash
    #!/bin/bash
    # Entrypoint script (entrypoint.sh)
    # Correct ownership of the mounted directory
    chown -R appuser:appgroup /data/mounted_volume
    # Execute the application as the non-root user
    exec gosu appuser "$@"
    ```

    Use this script by including an `ENTRYPOINT` directive in your Dockerfile:

    ```Dockerfile
    FROM base-image
    COPY entrypoint.sh /entrypoint.sh
    ENTRYPOINT ["/bin/sh", "entrypoint.sh"]
    CMD ["/usr/bin/myapp"]
    ```

    This will start the container with `/bin/sh entrypoint.sh /usr/bin/myapp`

    The entrypoint script will make the required permissions changes, then run /usr/bin/myapp as appuser.

#### Alternative Considerations

* **Named Volumes:** Use Docker-managed named volumes instead of host binds whenever possible. Docker manages the lifecycle and permissions of these volumes, effectively abstracting away host-level permission complexities. [stackoverflow](https://stackoverflow.com/questions/51188997/docker-uid-gid-mapping-changes-on-different-host)
* **Avoid "Open" Permissions:** Do NOT use `chmod 777` on host directories. While this resolves immediate "permission denied" errors, it introduces significant security risks by allowing any user on the system to read, write, or execute files within that directory. [stackoverflow](https://stackoverflow.com/questions/51188997/docker-uid-gid-mapping-changes-on-different-host)
* **User Namespace Remapping:** If your production environment supports it, configure the Docker daemon with user namespace remapping (`userns-remap`). This maps the container's root user to a non-privileged user on the host, providing an extra layer of security, though it requires careful planning for volume ownership. [github](https://github.com/docker/cli/issues/3086)

### Container exits immediately with exit code 0, and logs are empty. What common Dockerfile mistake cause this?

A Docker container exits immediately with code 0 when its PID 1 (main) process completes its execution. Because the process finishes successfully, Docker considers the container's task "done" and terminates it, even if you intended for it to be a long-running service.

#### Common Causes

Process running in background: You may be starting a service that daemonizes itself (e.g., Nginx, Apache) without disabling the daemon mode. When the process sends itself to the background, the container's PID 1 sees the parent task as finished and exits.

Non-long-running command: The CMD or ENTRYPOINT in your Dockerfile points to a utility or script that performs a single action and finishes (e.g., mkdir, echo, or a one-off script).

#### Troubleshooting and Fixes

* Debug with `tail -f`. To debug or keep a container alive, temporarily override the CMD to a process that never exits.

```bash
# Temporarily run this to keep the container alive while you inspect it
docker run -it <image-name> tail -f /dev/null
```

* Verify with Interactive Shell. Run the container interactively to manually execute your startup command and observe the output directly.

```bash
docker run -it <image-name> /bin/bash
# Once inside, run your application command manually
```

### Deleted a secret using RUN rm, but auditors still found it in the image layer. How? and what's the fix?

Docker images are composed of immutable layers. When you use `RUN rm` to delete a file, you are not actually removing the file from the image; you are simply creating a new layer that instructs the filesystem to mark that file as "hidden" in the final, combined view. The original data remains fully intact and accessible in the preceding layer's tarball. [aquilax](https://aquilax.ai/blog/docker-image-layer-secrets)

#### Why `RUN rm` Fails

* **Layer Immutability:** Docker layers are read-only snapshots. Once a layer is created, it cannot be modified. [aquilax](https://aquilax.ai/blog/docker-image-layer-secrets)
* **Historical Exposure:** Every layer is stored as a blob with its own content hash. An attacker with access to the image or the registry can extract the specific layer that originally contained the secret, bypassing the "deletion" performed in a later layer. [aquilax](https://aquilax.ai/blog/docker-image-layer-secrets)
* **Metadata Leaks:** If you use `ARG` to pass secrets during the build, the secret value itself is often recorded verbatim in the image history metadata, which is visible via `docker history`. [cloudnativenow](https://cloudnativenow.com/contributed-content/fresh-secrets-from-the-docks-what-15-million-docker-images-taught-us-about-cloud-security/)

#### The Correct Fixes

* **Use Docker Secrets (Recommended):** Use Docker's built-in `secret` functionality (e.g., in Docker Swarm or Kubernetes). Secrets are mounted into the container at runtime in an **in-memory filesystem** (`/run/secrets/`), ensuring they are never written to the image layers. [wiz](https://www.wiz.io/academy/container-security/docker-secrets)

  ```dockerfile
  FROM python:3.12-slim
  RUN --mount=type=secret,id=pip_token \
      pip install \
        --extra-index-url "$(cat /run/secrets/pip_token)" \
        -r requirements.txt
  ```

  Secret is passed at build time, never stored in any layer

  ```bash
  DOCKER_BUILDKIT=1  # Enable docker BuildKit
  docker build --secret id=pip_token,env=PIP_EXTRA_INDEX_URL -t myapp:latest .
  ```

* **Multi-Stage Builds:** In a multi-stage build, the final image is copied from an intermediate builder stage. If the secret-using operations happen only in the builder stage and only non-secret artifacts are COPY --from=builder'd into the final stage, the secret never reaches the final image at all.

  If you must use a secret to perform a build step (like installing a private package), perform the action in a temporary build stage and copy only the necessary build artifacts to the final, lean image. [aquilax](https://aquilax.ai/blog/docker-image-layer-secrets)

  ```dockerfile
  # Stage 1: Build with secret
  FROM python:3.12-slim AS builder
  ARG PIP_EXTRA_INDEX_URL
  RUN pip install --prefix=/install -r requirements.txt

  # Stage 2: final image - contains only the installed packages, not ARGs
  FROM python:3.12-slim
  COPY --from=builder /install /usr/local
  COPY . /app/
  CMD ["python", "-m", "app"]
  ```

* **BuildKit Secret Mounts:** If using BuildKit (the default builder in modern Docker), use the `--mount=type=secret` flag in your `RUN` instruction. This allows you to access secrets during the build without them being persisted in the resulting image layer. [cloudnativenow](https://cloudnativenow.com/contributed-content/fresh-secrets-from-the-docks-what-15-million-docker-images-taught-us-about-cloud-security/)

* **Scanning container images in CI before they reach the registry** The fix is preventive: scan images for secrets before pushing to the registry. Several tools can do this as a CI gate.

  * Trivy (`trivy image --scanners secret myapp:latest`) — scans layer content for secret patterns using a regex-based ruleset. Runs against the local daemon or an OCI archive.
  * Grype combined with Syft — Syft generates an SBOM with file hashes; Grype checks vulnerabilities. Neither scans for secrets natively, so combine with a dedicated secrets scanner.
  * AquilaX container scan — scans all image layers for secrets, PII, misconfigurations, and known CVEs in a single pipeline step, reporting before push.

  ```yaml
  - name: Build image
    run: docker build -t myapp:{{ github.sha }} .

  - name: Scan image for secrets
    run: |
      trivy image \
        --scanners secret \
        --exit-code 1 \
        --severity HIGH,CRITICAL \
        myapp:{{ github.sha }}

  # Push only happens if the scan step exits 0
  - name: Push to registry
    run: docker push myapp:{{ github.sha }}
  ```

#### Simulating deleted files

1. See `demo` directory in the current folder. Create `credentials.json` and `.env` as you want for the demo

2. Build a docker image

    ```bash
    docker build . -t myapp:latest
    ```

3. Save this image into a tarball

    ```bash
    docker save myapp:latest -o myapp.tar
    ```

4. Create a directory and extract this tar into that directory

    ```bash
    mkdir demo-layers
    tar xf myapp.tar -C demo-layers
    ```

5. The resultant directory would look like below file-structure:

    ```markdown
    demo-layers/
    ├── blobs/
    │   └── sha256/
    │       ├── 0d30b57f3fb6ed6c403a9b6ee5a16160c7d454393a981ac80d24fbcd5641bcc2
    │       ├── 2f9c67c20239ed8dbe550626a1c3dfee237fccb7d3de5286ccc6f97f11c6c6c0
    │       ├── 33aa2b899dd7804bcca493c672a49851847aef274035fbc22e0be3263829f394
    │       ├── 3a9714186f754e2ca86f9c6d4e8008da151101b99395194e0d3b948140e3a795
    │       ├── 48fa888e43a1e4f3b646cea884beadce98e46d5247bda8a39fc63d1b6d85bfbf
    │       ├── 4acebda804f2a04626e03b9b5532a12e53049c5dd3421d63ab9e978908005efc
    │       ├── 59d3e62b261cc62ea7b78c2400e056baaa025bdf2302256368ce83d95b7ec054
    │       ├── 6d7c150df58d41c351cd9b03f1cda7a9a23d6fc91436e2bf0f098c6dd78c9c55
    │       ├── 7e1b0e6d6e9ddbcefacce3c4502df32e3ee45e46937418b7c96fce2e85a0b017
    │       ├── 82f7b847f70975214b6b73f100ebdc64c70c10dfdaf8243766c7780682fa6819
    │       ├── 92d5072d497a898e1e46fb80d4ff79b2a8f4fff4810d1d45da10c9d4ee54a00c
    │       ├── 92f6e74e4a5402a52383533f4a17572b5c7d2b5183fe9ad8d9436476504ba511
    │       ├── 9539d972866db7bf682308c0b6d9ae6bb4b90512dd7b368986b6bfa647b74ab1
    │       ├── 9eba44eaea801d1b6bf07fbf41da1becbd2c9df5380c0b3db8bfdfda1d1eb2cd
    │       ├── ab62238abc728396c78d3907248de01442eb93a77ed70b01aedd7f87a5bc1a20
    │       ├── b6cbbcd77f2322ee8fe84f590c4826a1c00011595055f445706e2544eb73ab01
    │       ├── bbdbcef04a10de96e8a2b4db1e7e8016bbc59f29781f512fe292eb5c78e964ee
    │       ├── d6d1417b6e924eb009ac52bf36d8093dbafd42e53f087cdf0945a858b5260aa4
    │       ├── d841d8bfc327c8b5445f2c7f465a9bb872c1ba287fdddfa9cd1657dcfeadb8c3
    │       └── e1ed8e09cf5d7063f9bc9af99b6377f680dba6e9d4bfb60f59834752032d66ab
    ├── index.json
    ├── manifest.json
    ├── oci-layout
    └── repositories
    ```

6. Go into the `demo-layers` directory, and see `manifest.json`

    ```bash
    cd demo-layers
    cat manifest.json | jq
    ```

7. Pick a layer(digest) and extract it. Make sure that the layer file is of archive/compressed type

    ```bash
    $ file blobs/sha256/9539d972866db7bf682308c0b6d9ae6bb4b90512dd7b368986b6bfa647b74ab1
    blobs/sha256/9539d972866db7bf682308c0b6d9ae6bb4b90512dd7b368986b6bfa647b74ab1: POSIX tar archive

    # For POSIX tar archive
    tar -xf blobs/sha256/9539d972866db7bf682308c0b6d9ae6bb4b90512dd7b368986b6bfa647b74ab1

    # For gzip compressed data
    tar -xzf blobs/sha256/9539d972866db7bf682308c0b6d9ae6bb4b90512dd7b368986b6bfa647b74ab1
    ```

8. The extracted layer will create a directory and files according to what defined in that layer. (creating /root/credentials.json file)

9. (Optional) For reconstructing full filesystem, run below script

    ```bash
    mkdir rootfs
    for layer in $(jq -r '.[0].Layers[]' manifest.json); do
      tar -xf "$layer" -C rootfs
    done
    ```

    This ignores whiteouts properly (for full correctness you'd need overlayfs logic), but works for most inspection cases.

##### Find which layer introduced a specific file. The first layer where the file appears

```bash
for layer in $(jq -r '.[0].Layers[]' manifest.json); do
  echo "Checking $layer"
  tar -tf "$layer" | grep -E "^usr/bin/curl$" && echo "FOUND in $layer"
done
```

---

>**Handle deletions (whiteouts)**

Docker uses whiteout files:

* .wh.<filename> → deletes a file
* .wh..wh..opq → wipes a directory

Example:

```bash
tar -tf <layer> | grep '\.wh\.'
```

If you see: `usr/bin/.wh.curl`, That layer removes `curl`

##### Diff two layers (like Docker)

Let’s say:

* L1 = blobs/sha256/aaa
* L2 = blobs/sha256/bbb

1. Extract both:

    ```bash
    mkdir L1 L2
    tar -xf blobs/sha256/aaa -C L1
    tar -xf blobs/sha256/bbb -C L2
    ```

2. Run `diff`

    ```bash
    diff -qr L1 L2
    ```

    This shows:
    * added files
    * removed files
    * changed files

**NOTE**: This is NOT how docker truly diffs. This is just for educational purpose
