# Base

The base folder contains the deployment, service, and kustomization files. In this base folder, we add the deployment and service YAML with all the configs which could be common for all the environments.

## Deploying overlays/dev

We can use the below command to review the patches and check whether everything is correct or not.

```bash
kustomize build overlays/dev
```

It will render the below Kubernetes manifest as shown below.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  ports:
  - name: http
    port: 80
  selector:
    app: web
  type: NodePort
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - image: nginx:1.14.2
        name: nginx
        ports:
        - containerPort: 80
        resources:
          limits:
            cpu: "2"
            memory: 256Mi
          requests:
            cpu: "1"
            memory: 128Mi
```

We can deploy the customized manifest using the following command.

```bash
kustomize build overlays/dev | kubectl apply -f -
```

You can also use the following kubectl command.

```bash
kubectl apply -k overlays/dev
```

## Deploying overlays/prod

We can use the below command to review the patches and check whether everything is correct or not.

```bash
kustomize build overlays/prod
```

The replica and resource limit-requests will be increased.
