# FISSION - enables us to write serverless workloads on Kubernetes

Fission uses the Kubernetes native and custom resources very heavily to achieve serverless architecture

When we say serverless, we actually mean that the server/runtime to run your program/workload is not running when your workload is not getting any requests, or the server/runtime only runs when your workload is receiving any kind of requests. This architecture has several benefits from the traditional architecture where our servers run even when the workload deployed on those servers is not actually receiving any requests. One of the benefits that I can think of, of this architecture, on top of my head is the cost.

If your server/runtime only runs when the workload receives the request, you won’t be paying for the time when your function was not getting any requests.

Now, the above architecture has its own issues as well. For example, when your workload/program gets the first request it would take some time to start the server to serve that first request.

In other words, the first request that will be served is going to take a considerably large amount of time. The time that your serverless workload would take to serve the first request is often referred as Cold Start time and there are ways to resolve this issue.

## Components

### Environment

Environment has runtime or server that is going to host your Fission function.

For example, if you have your workload written in Python, you will create a Fission environment mentioning the Python runtime that you are going to use.

### Function

Fission functions are resources that are created to deploy your workload on Kubernetes. We can directly specify the code that a specific Fission function will host or we can specify the package after building the package out of the code.

If your function is going to use or is dependent on a `ConfigMap` or `Secret` resource you can specify that as well while creating the Fission function.

### Package

Packages are generally used when your workload has some external dependencies and it should be built with those external dependencies. In that case, you create the package and specify this package name instead of source code while creating the Fission function.

### Triggers

Once we have the function created, triggers are created **to decide how are we going to call a particular function**.

---

Fission uses Kubernetes custom resource very extensively and provides us with some custom resources, for example,

```yaml
canaryconfigs.fission.io
environments.fission.io
functions.fission.io
httptriggers.fission.io
kuberneteswatchtriggers.fission.io
messagequeuetriggers.fission.io
packages.fission.io
timetriggers.fission.io
```

## Installation

Install Fission in Kubernetes via Helm:

```bash
export FISSION_NAMESPACE="fission"
kubectl create namespace $FISSION_NAMESPACE
kubectl create -k "github.com/fission/fission/crds/v1?ref=v1.22.0"
helm repo add fission-charts https://fission.github.io/fission-charts/
helm repo update
helm install --version 1.22.0 --namespace $FISSION_NAMESPACE fission \
  --set serviceType=NodePort,routerServiceType=NodePort \
  fission-charts/fission-all
kubectl apply -f pv.yml
```

Install Fission CLI for creating functions, environments, and so on.

```bash
curl -Lo fission https://github.com/fission/fission/releases/download/1.22.0/fission-v1.22.0-linux-amd64 && chmod +x fission && sudo mv fission /usr/local/bin/
```

## Deploying NodeJS Code

You're ready to use Fission! You can create fission resources in the namespace "default"

```bash
# Create an environment
fission env create --name nodejs --image ghcr.io/fission/node-env --namespace default

# Get an example file
curl https://raw.githubusercontent.com/fission/examples/master/nodejs/hello.js > hello.js

# Register this function with Fission
fission function create --name hello --env nodejs --code hello.js --namespace default

# Run this function
$ fission function test --name hello --namespace default
Hello, world!
```

## Deploying Python Code

1. Create a Python environment

    ```bash
    fission env create --name python-env --image ghcr.io/fission/python-env --namespace default
    ```

2. Create a function out of the `main.py`

    ```bash
    fission fn create --name main-py --code main.py --entrypoint main.main --env python-env
    ```

3. Test above created function by passing a request body

    ```bash
    fission fn test --name main-py --body '{"name": "Harsh"}' --method POST
    ```

Once the function works as expected, we can create a trigger that will be used to call this function.

For example, if you want to call your function through an HTTP endpoint you will have to create an **HTTP trigger**.

There are other trigger types supported by Fission platform that can be found in this [Fission Document](https://fission.io/docs/usage/triggers/).

```bash
fission ht create --name main-py --url /main --method POST --function main-py
```
