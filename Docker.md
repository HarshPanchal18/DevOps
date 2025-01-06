
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
```plaintext
hello
```

However, if we run the same image with just the command to output the contents of the same file, we get an error:
```bash
$ docker run bash:latest bash -c "cat file.txt" 
cat: can't open 'file.txt': No such file or directory
```

