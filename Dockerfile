FROM golang:1.9-alpine3.6

EXPOSE 8080

WORKDIR /app

ADD bin/hello-world_linux_amd64 /app/helloworld

ENTRYPOINT ["/app/helloworld"] 
