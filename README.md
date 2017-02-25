# finntech/tomcat7

A base image for deploying a single [Java WAR file](https://en.wikipedia.org/wiki/WAR_(file_format)) into a [Tomcat 7](http://tomcat.apache.org/) servlet container.

This image is located [at Docker Hub](https://hub.docker.com/r/finntech/tomcat8/).

## Usage

Create a `Dockerfile` in the root of your project:

```Dockerfile
FROM finntech/tomcat8:<version>
COPY <your WAR file> /app
ENV CONTEXT_PATH some/path
ENV JVM_HEAP_RATIO 0.7
```

If `CONTEXT_PATH` is not specified, the webapp is deployed to the root context path.

The `JVM_HEAP_RATIO` (default value is 0.5) specifies how much of the container's memory
the JVM can use, that is, by using the `-Xmx` parameter to the JVM. If the memory limit for
the container is not set or is set too high (more than available on the host), the container
exits with an error message.

You can then build and run the Docker image:

```
$ docker build -t my-app .
$ docker run -it -p 9090:8080 my-app
```

This binds the Tomcat port (8080) inside the container to port 9090 on your Docker host machine.

The application is now available at `http://your-docker-host-ip:9090/some/path/`!

## Tags

The goal is that this image should be as static as possible, and the only tags that should happen are `${TOMCAT_MAJOR_VERSION}`.`${TOMCAT_MINOR_VERSION}`.`${TOMCAT_PATCH_VERSION}`. But since we're still working out how to do this, we might append a `-${FINN_INTERNAL_REVISION}` to the end of the tags.

Changes might include:

- deploy-and-run.sh optimizations
- serverinfo.jar upgrades
- base image updates


