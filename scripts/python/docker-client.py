import docker

client = docker.from_env()

containers = client.containers
images = client.images

print(images.list())
print(containers.list())

# https://docker-py.readthedocs.io/en/stable/containers.html#module-docker.models.containers
alpine = containers.run("alpine","echo hello world")
print(alpine
        .decode() # Convert raw bytes
        .strip()  # Removes \n
    )

spline_container = containers.run('bfirsh/reticulate-splines', detach=True, auto_remove=True)
print(spline_container.logs().decode())

# Fetch and print logs in real-time
for log_line in spline_container.logs(stream=True):
    print(log_line.decode('utf-8').strip())

containers.prune()
