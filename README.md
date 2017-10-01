# Go helloworld application using Minikube

## Requirements

- This application requires you to have a working Go environment (to run tests and build the static binary)
- Docker
- By default Minikube will use the "virtualbox" driver. If you do not override this, Virtualbox must be installed.

## Variables:

| Variable         | required | default value | Description                    |
| -----------------|:--------:|:-------------:| -------------------------------|
| MINIKUBE_DRIVER  | X        | virtualbox    | Minikube VM driver to use      |
| MINIKUBE_VERSION | X        | 0.22.1        | Version of minukube to install |
| KUBECTL_VERSION  | X        | 1.7.5         | Version of kubectl to install  | 

## Running the thing:

This needs to be in your ~/go/src/github.com/joshmyers/helloworld directory. Use `go get github.com/joshmyers/helloworld`, unzip to this location etc.

```
$ make
make
minikube_install               Install minikube
kubectl_install                Install kubectl
minikube_start                 Start minikube
minikube_stop                  Stop minikube
minikube_dashboard             Open Minikube dashboard
go_fmt                         Run gofmt over all *.go files
test                           Run tests
build_app                      Build Go binary for all GOARCH
build_container                Build Docker container
build                          Run tests, build application, build container
run_app                        Run app in Minikube
all                            Start Minikube, run tests, build app, build container, run app
```

Example usage:

```
$ make all
==> Checking Minikube installed - installing if not...
==> Minikube minikube version: v0.22.1 installed...
==> Checking Kubectl installed - installing if not...
==> Kubectl Client Version: version.Info{Major:"1", Minor:"7", GitVersion:"v1.7.5", GitCommit:"17d7182a7ccbb167074be7a87f0a68bd00d58d97", GitTreeState:"clean", BuildDate:"2017-08-31T09:14:02Z", GoVersion:"go1.8.3", Compiler:"gc", Platform:"darwin/amd64"} installed...
==> Starting Minikube with the "virtualbox" driver
Starting local Kubernetes v1.7.5 cluster...
Starting VM...
Downloading Minikube ISO
 106.36 MB / 106.36 MB [============================================] 100.00% 0s
Getting VM IP address...
Moving files into cluster...
Setting up certs...
Connecting to cluster...
Setting up kubeconfig...
Starting cluster components...
Kubectl is now configured to use the cluster.
==> Running tests...
=== RUN   TestHelloWorld
--- PASS: TestHelloWorld (0.00s)
PASS
ok  	_/Users/joshmyers/Desktop/helloworld/helloworld	0.017s
==> Building hello-world for all GOARCH/GOOS...
==> Building container...
Sending build context to Docker daemon 8.822 MB
Step 1 : FROM golang:1.9-alpine3.6
1.9-alpine3.6: Pulling from library/golang
88286f41530e: Pull complete
3f27971ac235: Pull complete
91367c599182: Pull complete
8577260f1836: Pull complete
5b99bfbf214e: Pull complete
e21738584314: Pull complete
Digest: sha256:e91ddbf20f44daeba9a9eca328bc8dbaccf790d26d017dfc572bc003f556e42d
Status: Downloaded newer image for golang:1.9-alpine3.6
 ---> ed119d8f7db5
Step 2 : EXPOSE 8080
 ---> Running in fc832ab976b1
 ---> b0bf3eea2106
Removing intermediate container fc832ab976b1
Step 3 : WORKDIR /app
 ---> Running in 3d4152726a5c
 ---> 415b3ed47c80
Removing intermediate container 3d4152726a5c
Step 4 : ADD bin/hello-world_linux_amd64 /app/helloworld
 ---> 6c6b98822653
Removing intermediate container 36a6f2e02dbe
Step 5 : ENTRYPOINT /app/helloworld
 ---> Running in 035f673ff951
 ---> 7873c75e053e
Removing intermediate container 035f673ff951
Successfully built 7873c75e053e
==> Running app hello-world:1ec4cc9
deployment "hello-world" created
service "hello-world" exposed
Waiting, endpoint for service is not ready yet...
==> Service exposed at http://192.168.99.100:31340
```
