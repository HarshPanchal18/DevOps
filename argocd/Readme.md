# GitOps - A Simple, Consistent, and Secure approach to manage your environments

## Index

- [Problem](#problem)
- [Solution](#solution)
- [Introduction](#argocd---a-declarative-gitops-cd-tool-based-on-kubernetes)
- [ArgoCD Application - Deploying Resources in a cluster](#argocd-applications---deploying-resources-in-a-cluster)
- [ArgoCD Projects - A logical grouping of ArgoCD Applications](#argocd-projects---a-logical-grouping-of-argocd-applications)
- [Cluster Management](#cluster-management)
- [Add New Cluster](#add-a-kubernetes-cluster-to-deploy-applications-through-argocd)
- [Local User Management](#local-user-management)
- [RBAC Authorization](#rbac-authorization)
- [ArgoCD ApplicationSet - Manage multiple applications across different environments or clusters](#argocd-applicationset---manage-multiple-applications-across-different-environments-or-clusters)
- [Context Switching](#context-switching-troubleshooting)
- [Rollouts](#rollouts)
- [ArgoCD Hooks](#argocd-hooks---run-kubernetes-jobs-around-the-argocd-application-sync)
- [Resource creation order](#create-resources-in-order)
- [Configure GitHub webhook with ArgoCD](#configure-github-webhook-with-argocd)
- [Authenticating with OAuth App in GitHub](#authenticating-with-oauth-apps-in-github)
- [GitHub Authorization with GitHub App](#github-authorization-with-github-app)
- [Configuration Tweaks](#configuration-tweaks)
- [Disaster Recovery](#disaster-recovery)
- [Auditing in ArgoCD](#auditing-in-argocd)
- [ArgoCD API Exposure](#argocd-api-exposure)
- [Rotate Redis Secrets](#rotate-redis-secret)
- [Config-Management-Plugin in Argo CD - Defining custom logic to generate YAML](#configuring-cmp-configuration-management-plugin)
- [Configuring MCP Server for Argo CD in VS Code](#configuring-mcp-server-for-argo-cd-in-vs-code)
- [Cluster cache sequence](#sequence-of-cluster-cache-processed-via-application-controller)

## Problem

1. You started running your app on your own computers and servers.
2. Now, you're running it in a mix of your own servers and shared cloud environments (a "hybrid" setup).
3. This means you have to manage many different groups of servers and computers ("multiple clusters").
4. Making even a small update to the app is complicated because you have to push that change to every one of those server groups.

## Solution

1. Developers will continue to save their new code on a central platform like GitHub.
2. You can set up a special location (a "repository") that acts as a single "master plan" for everything:
3. The settings for your infrastructure (the computer systems and servers).
4. The configuration for your services (the app itself).
5. This single master plan will allow you to manage and update all your different server groups with confidence and consistency.

## ArgoCD - A declarative GitOps CD tool based on Kubernetes

- **Declarative**: Making sure that deployment and the architecture you want to have in production is exactly as you want it to be. (How the architecture is going to look like.)
- **Simple**: Architecture & Management (Lightweight in Kubernetes)
- **Consistent**: Avoiding the "Pipeline Snowflake" (No configuration drifts)
- **Secure**: Pull vs. Push
  - Models:
    - **Push-based** Manifest in repo triggers CI system which deploys the app on Kubernetes cluster
    - **Pull-based** Pull manifest from the repo to sync with kubernetes cluster

### How it works

Creates a `controller` which continuously monitors running application and compare it's state against desired target state

- **Target state** - Defined in Git repository
- **Live state** - Deployed in Kubernetes cluster

`Sync` -  No differences among state
`OutOfSync` -  There is a difference

### Components

- **API Server** - gRPC/REST server which exposes API consumed by UI, CLI, or CI pipeline
- **Repository Service** - An internal service maintains cache of manifest. Stored in Redis
- **Application controller** - Compare the TARGET state and LIVE state. Optionally take corrective action.

## ArgoCD Applications - Deploying Resources in a cluster

ArgoCD Application is a fundamental unit of deployment in ArgoCD.

It represents:

- **what to deploy?** - git repo, helm chart
- **where to deploy?** - cluster, namespace
- **how it should be managed?** - sync, rollbacks

Each Application is independent and lifecycle-managed by Argo CD.

### Core components

- `source` - where the manifests come from. (git repo, helm chart or kustomize overlay)
- `destination` - where the application is deployed. (server, namespace)
- `project` - in what ArgoCD project to deploy
- `syncPolicy` - controls how ArgoCD apply changes to the ArgoCD application

### Application Lifecycle

1. Application is created (manually or via ApplicationSet)
2. ArgoCD fetches manifests from the source
3. Desired state is compared with live cluster state
4. Differences are shown as OutOfSync
5. Sync applies changes to reach Synced state
6. Continuous reconciliation keeps state consistent

### Sync status

- `Sync` - Current state and desired state of the application are consistent
- `OutOfSync` - There are differneces in manifest between current and live state

### Health status

- **Healthy** - Resources are 100% healthy
- **Degraded** - There is a failure while deploying (namespace doesn't exist, image not found, or any other kubernetes error)
- **Processing** - Calculating health for all the components
- **Missing** - The resources does not exist in cluster
- **Suspended** - The resource is paused or in suspended state (a paused deployment, suspended cronjob)
- **Unknown** - The health calculation has failed

### Sync Options for Application

#### `syncPolicy` - controls when and how a sync will be performed

- `syncPolicy.automated` - keep an application synced to the target revision
- `syncPolicy.automated.prune` - whether to delete resources from the cluster that are not found in the sources anymore (default: `false`)
- `syncPolicy.automated.selfHeal` - whether to revert resources back to their desired state upon modification in the cluster (default: `false`)

#### `syncPolicy.syncOptions` - allow to specify whole app **sync-options**

- `syncPolicy.syncOptions.CreateNamespace=true` - Creates namespace if it doesn't exist.
- `syncPolicy.syncOptions.ApplyOutOfSyncOnly=true` - To sync only **OutOfSync** resources. By default ArgoCD syncs all the resources. This may fill up API Server if there are large number of resources.
  - You can check **Result** of which resources are synced by clicking on **SYNC STATUS**.
- `syncPolicy.syncOptions.Replace=true` - Replace the changes instead of **Apply**ing.
  - `kubectl apply` is limited to smaller changes relatively.
  - To make this apply for selective resource(s), prefer passing annotations to each resources.
- `syncPolicy.syncOptions.FailOnSharedResource=true` - If a resource is already deployed in same namespace via other application, mark `application` as **OutOfSync** with warnings such as "_Service/nginx is a part of applications argocd/ application1 and application2_".
- `syncPolicy.syncOptions.PruneLast=true` - To prune resource/application after all other resources/applications are pruned.

#### Resource Level

Annotate resource(s) with:

- `argocd.argoproj.io/sync-options: Prune=false` - to prevent from being delete by **syncPolicy.automated.prune**.
- `argocd.argoproj.io/sync-options: Validate=false` - to disable schema validation of resource, silently dropping any unknown or duplicate fields.
  - Similar to `kubectl apply -f resource.yaml --validate='ignore'`.
- `argocd.argoproj.io/sync-options: Delete=false` - to retain resources even after application is deleted. (e.g. PersistentVolumeClaim)
- `argocd.argoproj.io/sync-options: Delete=confirm` - to require manual confirmation before deletion.
  - To confirm the deletion, annotate the application with `argocd.argoproj.io/deletion-approved: ISO-Timestamp`

#### Formation

```yaml
syncPolicy:
  automated:                   #  Sync autmatically based on refresh timeout or manually. Default timeout: 3min
    prune: true                #  Delete resources if it's manifest is deleted from the source
    selfHeal: true             #  Revert changes made in the cluster manually
    syncOptions:
      CreateNamespace=True     #  Create namespace if it doesn't exist
      ApplyOutOfSyncOnly=True  #  Sync OutOfSync resources only.
      ServerSideApply=True     #  Apply changes as kubectl apply --server-side. For applying larger resource ( >262.14KB)
      PruneLast=True           #  Prune the resource at very last (after healthy status)
      Replace=True             #  Replace the resource with kubectl replace or kubectl create.
      Validate=True            #  If need to validate schema or silently dropping any unknown or duplicate fields
```

See examples of Application under **`applications`** directory

### Sync ArgoCD Application from Kubernetes cluster

[Reference](https://argo-cd.readthedocs.io/en/stable/user-guide/sync-kubectl)

Patch ArgoCD application with following block to invoke sync for resources (deployments, services, etc...):

```yaml
operation:
    initiatedBy:
        username: <username> # unrelated custom values
    sync:
        syncStrategy:
            hook: {}
```

## ArgoCD Projects - A logical grouping of ArgoCD Applications

- [Documentation Link](https://argo-cd.readthedocs.io/en/stable/user-guide/projects/)

Default created project in ArgoCD: `default`

### High level usecase

| Topic | Description |
|---|---|
| Repository Whitelisting | Allow/Deny ArgoCD to deploy YAMLs from the given GitHub Repo format only |
| Cluster scoped Resource Whitelisting/Blacklisting | Allow/Deny kubernetes cluster scoped object creation via ArgoCD Applications |
| Namespace scoped Resource Whitelisting/Blacklisting | Allow/Deny kubernetes namespace scoped object creation via ArgoCD Applications |
| Target namespace Whitelisting | Allow/Deny object creation in given namespace in given clusters via ArgoCD Applications |
| Project Scoped Roles | To define project scoped roles for RBAC |
| Orphan Resource Monitoring | To display orphan resources which are not handled via ArgoCD |
| Sync Windows | Suspending Auto/Manual sync for one or more ArgoCD Applications on given time frame |

### Detailed Configuration for ArgoCD Project

Detailed Configuration of ArgoCD Project

- Ensures that project is not deleted until it is not referenced by any application

```yaml
  metadata:
    finalizers:
    - resources-finalizer.argocd.argoproj.io
```

---

Set following configuration under `AppProject.spec`

- Project Description

```yaml
description: "Project Description"
```

- Allow manifests to deploy from the given GitHub Profile only

```yaml
sourceRepos:
- 'https://github.com/your-org/*'
```

- Deny applications to deploy resources in kube-system namespace and argocd namespace in any cluster

```yaml
destinations:
- namespace: "!kube-system"
    server: "*"
- namespace: "!ns-argocd"
    server: "*"
```

- Allow creation of ClusterRole via ArgoCD Application

```yaml
clusterResourceWhitelist:
- group: ''
  kind: ClusterRole
  name: '*'
```

- Deny creation of Gateway resources via ArgoCD Application

```yaml
clusterResourceBlacklist:
- group: ''
  kind: Gateway
  name: '*'
```

- Allow creation of Deployments and Statefulesets via Application

```yaml
namespaceResourceWhitelist:
- group: 'apps'
  kind: Deployment
- group: 'apps'
  kind: StatefulSet
  name: '*'
```

- Deny creation of Secrets via Application

```yaml
namespaceResourceBlacklist:
- group: ''
  kind: Secret
  name: '*'"
```

- Detect ArgoCD application created in ns-prod namespace and argocd namespace (if Applications in Any namespace is enabled)

```yaml
sourceNamespaces:
- ns-prod
```

- Create roles scoped to the project. Not ArgoCD Global scope

```yaml
roles:
- name: read-only
  policies:
  - p, proj:my-project:read-only, applications, get, my-project/*, allow
```

- Deny Application sync for given application from 10am to 11am everyday

```yaml
syncWindows:
- kind: deny
  schedule: '* 10 * * *'
  duration: 1h
  applications:
  - 'application*'
```

- Detecting orphaned resources, inspecting/removing resources using the Argo CD UI, and generating a warning.

```yaml
orphanedResources:
  warn: true
```

### Restricting Applications using Projects in different ways

1. `sourceRepos`: White listing repository to deploy from only given repository.

    ```yaml
    sourceRepo:
        - https://github.com/user-abc/repo-xyz # Consider this repository only (Whitelisting)
        - !https://github.com/user-abc/repo-xyz # Blacklisting repository
        - '*' # All
    ```

2. `destinations`: Where to deploy Application

    ```yaml
    destinations:
        namespace: 'dev' # Install in dev namespace only. Put "!" prefix for inverse
        server: 'https://kubernetes.default.svc' # Install in given server only
    ```

3. `clusterResourceWhitelist` and `namespaceResourceWhitelist`: Restrict application based on the Kubernetes resource(s).

    ```yaml
    clusterResourceWhitelist:
        - group: ""
          kind: "Namespace" # Application can use namespace resource but not allowed to use other resource
    namespaceResourceWhitelist:
        - group: "apps"
          kind: "Deployment" # We only allow Deployments
    namespaceResourceBlacklist:
        - group: "apps"
          kind: "Deployment" # We only deny Deployments
    ```

After applying these conditions (e.x. `sourceRepo`), the status of the deployed application would be of **Unknown** status and errors in the conditiions saying "_InvalidSpecError: application repo is not permitted in project_" if an application violates any whitelist or conditions.

### `SyncWindows` in ArgoCD Projects

A configurable windows of time where syncs will either be **blocked** or **allowed**

Three ways for selecting the Application resources to which a Sync Window applies

| No. | Entity | Location |
|---|---|---|
| 1 | By Application name | AppProject.spec.syncWindows[*].applications |
| 2 | By Cluster name into which Applications are created | AppProject.spec.syncWindows[*].clusters |
| 3 | By Namespace into which Applications are created | AppProject.spec.syncWindows[*].namespaces |

- All above three fields support wildcards
- Selection conditions are evaluated as OR condition by default
- These condition(s) affect the matching applications whether they are configured to Auto Sync or Manual Sync

**Example**: Deny sync for every "application*" from 10am to 11am everyday

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: project1
  namespace: ns-argocd
spec:
  # ...
  syncWindows:
    - kind: deny # or allow
      schedule: '* 10 * * *'
      duration: 1h
      applications:
        - 'application*'
```

#### Configurations for syncWindows

| Configuration | Meaning | Importance |
|---|---|---|
| **kind** | action to enforce (deny/allow) | _required_ |
| **schedule** | cronjob to enforce deny or allow | _required_ |
| **duration** | duration of time window | _required_ |
| **applications** | list of application on which it is applied | _required_ |
| **namespaces** | list of namespace to look for application | _optional_ |
| **clusters** | list of cluster to look for application | _optional_ |
| **andOperator** | evaluate conditions as AND for (applications, namespaces, and clusters) | _optional_ |
| **manualSync** | whether to allow manual sync during the sync window | _optional_ |
| **timezone** | timezone for the cronjob | _optional_ |

- If no windows match any application: All applications are allowed to sync
- If any application matched in both `allow` and `deny`: Sync will be denied as deny window overrides allow window

The application UI has a panel which will display different colours depending on the state of window

- **Red** - Sync denied
- **Orange** - Manual sync allowed only
- **Green** - Sync allowed

## Cluster management

Cluster credentials are stored in secrets same as repositories or repository credentials.

Each secret must have label `argocd.argoproj.io/secret-type: cluster`.

The secret data must include following fields:

- `name` - cluster name
- `server` - cluster api server url
- `namespaces` - optional comma-separated list of namespaces which are accessible in that cluster. Setting namespace values will cause cluster-level resources to be ignored unless `clusterResources` is set to `true`.
    > When `namespaces` is set, Argo CD will perform a separate **list/watch** operation for each namespace. This can cause the Application controller to exceed the maximum number of idle connections allowed for the Kubernetes API server. To resolve this issue, you can increase the **ARGOCD_K8S_CLIENT_MAX_IDLE_CONNECTIONS** environment variable in the **Application controller**.

- `clusterResources` - optional boolean string ("true" or "false") determining whether Argo CD can manage cluster-level resources on this cluster. This setting is only used when namespaces are restricted using the `namespaces` list.
- `project` - optional string to designate this as a project-scoped cluster.
- `config` - JSON representation of the following data structure:

    ```yaml
    # Basic authentication settings
    username: string
    password: string

    # Bearer authentication settings
    bearerToken: string

    # IAM authentication configuration
    awsAuthConfig:
        clusterName: string
        roleARN: string
        profile: string

    # Configure external command to supply client credentials
    # See <https://godoc.org/k8s.io/client-go/tools/clientcmd/api#ExecConfig>
    execProviderConfig:
        command: string
        args: [
            string
        ]
        env: {
            key: value
        }
        apiVersion: string
        installHint: string

    # Proxy URL for the kubernetes client to use when connecting to the cluster api server
    proxyUrl: string

    # Transport layer security configuration settings
    tlsClientConfig:
        # Base64 encoded PEM-encoded bytes (typically read from a client certificate file).
        caData: string
        # Base64 encoded PEM-encoded bytes (typically read from a client certificate file).
        certData: string
        # Server should be accessed without verifying the TLS certificate
        insecure: boolean
        # Base64 encoded PEM-encoded bytes (typically read from a client certificate key file).
        keyData: string
        # ServerName is passed to the server for SNI and is used in the client to check server
        # certificates against. If ServerName is empty, the hostname used to contact the
        # server is used.
        serverName: string

    # Disable automatic compression for requests to the cluster
    disableCompression: boolean
    ```

## Add a Kubernetes cluster to deploy applications through ArgoCD

The `bearerToken` is essentially a digital key (a Service Account Token) that gives Argo CD permission to talk to your remote cluster’s API server.

When Argo CD manages a remote cluster, it doesn't log in as "you." Instead, it logs in as a Service Account with specific permissions to create, update, and delete resources (like Pods and Deployments) on that cluster.

### How the Token Works

- Think of it as a permanent login session for a "**robot**" user.
- Target Cluster: You create a Service Account (usually named argocd-manager).
- Target Cluster: You give that account `cluster-admin` rights.
- Target Cluster: Kubernetes generates a long string of characters (the token).
- Argo CD Hub: You give this string to Argo CD so it can "prove" it has permission to manage the target cluster.

When Argo CD manages a remote cluster, it logs in as a Service Account with specific permissions to create, update, and delete resources (like Pods and Deployments) on that cluster.

### Add a cluster in ArgoCD to deploy applications

1. Create a Service Account on a target cluster.

    ```bash
    kubectl create sa argocd-manager -n kube-system
    ```

2. Assign `cluster-admin` rights to this Service Account.

    ```bash
    kubectl create clusterrolebinding argocd-manager-role --clusterrole=cluster-admin --serviceaccount=kube-system:argocd-manager
    ```

3. We need a Bearer Token of target cluster to get communicated with ArgoCD.

    The token is generated by creating a secret of type kubernetes.io/service-account-token on target cluster.

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
        name: argocd-manager-token
        namespace: kube-system
        annotations:
            kubernetes.io/service-account.name: argocd-manager
    type: kubernetes.io/service-account-token"
    ```

4. After applying, extract the token.

    ```bash
    kubectl -n kube-system get secret argocd-manager-token -o jsonpath='{.data.token}' | base64 -d
    ```

5. Put this `token` and `caData` (Certifiacte Authority Data) of target cluster (`cat ~/.kube/config`) inside below secret.

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
        name: gke-cluster-secret
        namespace: argocd
        labels:
            argocd.argoproj.io/secret-type: cluster
    type: Opaque
    stringData:
        name: gke-cluster
        server: SERVER-URL
        namespaces: "staging,dev,uiportal-beta" # Namespace(s) allowed to manage on target cluster
        config: |
            {
                "bearerToken": "BEARER-TOKEN",
                "tlsClientConfig": {
                    "insecure": true,
                    "caData": "ENCODED-CA-DATA"
                }
            }
    ```

    Or for configuring directly in helm `values.yaml`:

    ```yaml
    configs:
        clusterCredentials:
            toy-cluster: # This would be referred as a `name` of your cluster
                server: https://toy.cluster.com
                labels: {}
                annotations: {}
                config:
                    bearerToken: "<BEARER-TOKEN>"
                    tlsClientConfig:
                    insecure: false
                    caData: "<base64 encoded certificate>"
    ```

6. Apply above secret in a cluster where ArgoCD is deployed.
7. After applying this secret, ArgoCD sync target cluster automatically.
8. Check if the target cluster is added successfully into ArgoCD by visiting: <https://argocd.example.com/settings/clusters>

### Important Security Note

- > Handle with care: Anyone with this token has full cluster-admin access to your target cluster.

- > Use the CLI if possible: When you run `argocd cluster add <name>`, the CLI does all of the steps above automatically for you, including generating the token and creating the secret in Argo CD. It is much safer and easier.

## Local User Management

### Create new user with password

New user should be defined in `argocd-cm` Configmap.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
    name: argocd-cm
    namespace: argocd
    labels:
        app.kubernetes.io/name: argocd-cm
        app.kubernetes.io/part-of: argocd
data:
    # add an additional local user with apiKey and login capabilities
    #   apiKey - allows generating API keys
    #   login - allows to login using UI
    accounts.local-user: apiKey, login
    accounts.local-user.enabled: "false" # disables user. User is enabled by default
```

Each user might have two capabilities:

- `apiKey` - allows generating authentication tokens for API access
- `login` - allows to login using UI

Or via Helm `values.yaml`:

```yaml
configs:
    cm:
        accounts.local-user: login
```

Create/Set a password for the above user:

```bash
# Install below package first to generate password
$ sudo apt install apache2-utils

# Generate a hash for a password (e.x. secretpassword)
$ htpasswd -nbBC 10 "" secretpassword | tr -d ':\n' | sed 's/$2y/$2a/'

# e.x. $2a$10$dwC0Wu4eEXe0.LgUEpwlvOkqMwUaFyaIf0oxTWYpE4yoxxTQsvjfy
```

Patch/Set above generated hash inside `secret/argocd-secret` to apply a password for user `local-user`:

```bash
kubectl -n argocd patch secret argocd-secret -p '{"stringData": { "local-user.password": "$2a$10$dwC0Wu4eEXe0.LgUEpwlvOkqMwUaFyaIf0oxTWYpE4yoxxTQsvjfy" }}'
```

Restart `pod/argocd-server`:

```bash
kubectl -n argocd delete pods -l app.kubernetes.io/name=argocd-server
```

### Get user list

```bash
argocd account list
```

### Get user account detail

```bash
argocd account get --account local-user
```

### Delete user

In order to delete a user, remove the corresponding entry defined in the `argocd-cm` ConfigMap:

Example:

```bash
kubectl patch -n argocd cm argocd-cm --type='json' -p='[{"op": "remove", "path": "/data/accounts.local-user"}]'
```

It is recommended to also remove the password entry in the `argocd-secret` Secret:

Example:

```bash
kubectl patch -n argocd secrets argocd-secret --type='json' -p='[{"op": "remove", "path": "/data/accounts.local-user.password"}]'
```

### Change password

```bash
# Login with username
$ argocd account login argocd-server.argocd.svc --username local-user
Password:

# Update password
$ argocd account update-password --account local-user
*** Enter password of currently logged in user (local-user):
*** Enter new password for user local-user:
*** Confirm new password for user local-user:
Password updated
Context 'argocd-server.argocd.svc' updated
```

### Generate auth token (optional)

This allows the account to generate and use authentication tokens for API access.

```bash
# if flag --account is omitted then Argo CD generates token for current user
argocd account generate-token --account local-user
```

Encode the generated token and put inside `argocd-secret` secret as `accounts.local-user.

### Reset password

```bash
# Generate token
$ htpasswd -nbBC 10 "" new-password | tr -d ':\n' | sed 's/$2y/$2a/'

# e.x. $2a$10$UAJR/PVjG9UcjVhQSLNike1j9LilJA6vYlJw/yuZ6/kJ3903N/dm6

# Patch secret/argocd-secret to update value
kubectl -n argocd patch secret argocd-secret -p '{"data": {"local-user.password": "$2a$10$UAJR/PVjG9UcjVhQSLNike1j9LilJA6vYlJw/yuZ6/kJ3903N/dm6" }}'

# Restart pod/argocd-server (optional)
kubectl -n argocd delete pods -l app.kubernetes.io/name=argocd-server
```

### Reset Admin password

To reset the ArgoCD admin password it is required to delete the values of admin.password and admin.passwordMtime that are stored as K8s secret object argocd-secret in the namespace in which ArgoCD is installed (default argocd)

```bash
$ kubectl patch secret -n argocd argocd-secret -p '{"data": {"admin.password": null, "admin.passwordMtime": null}}'
- sample output -
secret/argocd-secret patched
```

Restart ArgoCD server to generate the new admin password

```bash
$ kubectl rollout restart deployment.apps/argocd-server -n argocd
- sample output -
deployment.apps/argocd-poc-server restarted

```

The new admin password will be saved as argocd-initial-admin-secret object, that can be retrieved as follows

```bash

$ kubectl get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
- sample output -
RCUmfqHpZrwHXUUt
```

Log into ArgoCD using the new admin password:

```bash
$ argocd login <ARGOCD_URL> --username admin --password ******* --skip-test-tls --grpc-web
- sample output -
'admin:login' logged in successfully
Context '<ARGOCD_URL>' updated
```

To change the ArgoCD admin password, execute:

```bash
$  argocd account update-password
- sample output -
***Enter password of currently logged in user (admin):
*** Enter new password for user admin:
*** Confirm new password for user admin:
Password updated
Context '<ARGOCD_URL>' updated
```

Change local user password

```bash
argocd account update-password --server argocd-server.argocd.svc --insecure --account local-user
```

## RBAC Authorization

A role is an RBAC entity, defines a set permissions for accessing ArgoCD resources.
It provides Access Control for users and groups.

### What is Role in ArgoCD?

A role is an RBAC entity, defines a set permissions for accessing ArgoCD resources.
It provides Access Control for users and groups.

#### Types of Roles

##### Global Scoped

- Provide access control over all ArgoCD resources
- Defined within argocd-rbac-cm configmap
- Supported Resources for the policy:  **Applications**, **ApplicationSet**, **Repository**, **Cluster**, **Accounts**, **Logs**, **Exec**, **GpgKey**, **Certificates**

##### Project Scoped [Read more](https://argo-cd.readthedocs.io/en/stable/user-guide/projects/#project-roles)

- Provide access control scoped to the specific ArgoCD Project
- Defined within ArgoCD Project
- Supported Resources for the policy:  **Applications**, **ApplicationSet**, **Repository**, **Cluster**, **Logs**, **Exec**

##### Default Roles

There are two roles comes inbuilt with ArgoCD

- `role:admin` : unrestricted access to all resources
- `role:readonly` : read-only access to all resources

These role's policies are described in [this](https://github.com/argoproj/argo-cd/blob/master/assets/builtin-policy.csv) file

#### Custom Roles

- We can create new role and can bind with one or more Groups and Users
- If a role has not assigned any policy, then `policy.default` defined in `argocd-rbac-cm` is applied for that role.
- If a role has permissions defined **Global-scope** and **Project-scope**, both will combined with `deny` policy taking precedence over `allow`.

### Default local User

- Default local `admin` user is created by default. We can set password for it during/after ArgoCD installation.
- It is assigned with `admin` Role.
- We can disable this account after the installation.

ArgoCD RBAC configuration can be found inside `argocd-rbac-cm` configmap.

_Default:_

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
    name: argocd-rbac-cm
    namespace: argocd
data:
    policy.csv: ""
    policy.default: ""
    policy.matchMode: glob
    scopes: '[groups]'
```

[RBAC Model](https://argo-cd.readthedocs.io/en/stable/operator-manual/rbac/#rbac-model-structure)

### RBAC supports below resources

| Resource     | Meaning              |
| ------------ | -------------------- |
| applications | Argo CD Applications |
| projects     | AppProjects          |
| repositories | Git repos            |
| clusters     | Destination clusters |
| logs         | Pod logs             |
| exec         | Pod exec             |
| certificates | TLS certs            |
| accounts     | Argo CD accounts     |

### Common actions

| Action   | Meaning                  |
| -------- | --------------------     |
| get      | View ArgoCD Resources                     |
| create   | Create ArgoCD Resources                   |
| update   | Modify ArgoCD Resources                   |
| delete   | Delete ArgoCD Resources                   |
| sync     | Sync applications                         |
| override | Change Application params                 |
| action   | Perform [actions](https://argo-cd.readthedocs.io/en/stable/operator-manual/resource_actions/#built-in-actions) on resource      |
| invoke   | Invoke proxy extensions (alpha feature)   |

Design policies to provide **least required** privileges.

- Line starts with `p,` considered as a policy (What a role can do).
- Line starts with `g,` considered as a policy (Maps group (imported from SSO) with role).

```yaml
data:
    policy.csv: |
        p, role:dev, applications, get, dev/*, allow
        p, role:dev, applications, sync, dev/*, allow

        p, role:admin, *, *, *, allow

        g, my-org:backend, role:dev
        g, my-org:frontend, role:dev
        g, my-org:platform, role:admin

    policy.default: "role:readonly" # Anyone not mapped explicitly gets read-only access
```

In above policy, `backend` team can `get` and `sync` applications only, while `admin` team have full access of all the reources.

> **Groups are imported, roles are invented, permissions are attached.**

### Debugging RBAC

Check who you are:

```bash
argocd account get-user-info
```

Check groups:

```bash
argocd account get-user-info --show-groups
```

Test access:

```bash
argocd admin settings rbac can dev-team applications sync myproj/app1
```

## ArgoCD ApplicationSet - Manage multiple applications across different environments or clusters

- Enables both automation and greater flexibility managing Argo CD Applications across a large number of clusters.
- Use a single Kubernetes manifest to target multiple Kubernetes clusters and to deploy multiple applications from one or multiple Git repositories with ArgoCD

Important sections in ApplicationSet:

1. `syncPolicy` - defines sync policy for generated applications
2. `generators` - generating multiple values for application(s) to be created
3. `template` - creates application by utilising values generated via generators

### `syncPolicy` - Managed Applications modification Policies

The ApplicationSet controller supports a parameter `--policy`, which restricts what types of modifications will be made to managed Argo CD Application resources.

You can enforce this parameter by providing argument within the Controller Deployment container (`application-controller`)

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
# ...
spec:
    # ...
    syncPolicy:
        applicationsSync: create-only # create-update, create-delete, sync
```

Enumerated values for `applicationsSync`:

| Policy | Allows | Prevents |
|---|---|---|
| `create-only` | **Create** Application resources | **Deletion** or **Modification** |
| `create-update` | **Create** or **Modify** Application resources | **Deletion** |
| `create-delete` | **Create** or **Delete** Application resources | **Modification** |
| `sync` | **Create**, **Modification** and **Delete** | Nothing |

### Generators - generating parameters for ArgoCD application

- Parameters are **key-values** pairs that are substituted into the `template` section of the **ApplicationSet** resource during template rendering.
- You can call parameter values as `{{keyname}}`

All supported configuration for generators in ApplicationSet are [given here](https://github.com/argoproj/argo-cd/blob/master/docs/operator-manual/applicationset.yaml)

#### Types of Generator

##### List Generator

- generates parameters based on a fixed list
- you can give any valid custom key value pairs
- if a non-existent key is referenced in template, it will rendered as it is. (e.x. namespace: {{namespace}})
- **Applicable for flexible values**

- list or nested type is not supported.

```yaml
generators:
  - list:
      elements:
        - authors:
            - men
            - women
        - authors:
            - robot:
                bots: chat
```

##### Cluster Generator

- Generates cluster parameters based on the **clusters** that are defined within Argo CD.
- Auto detect below fields from **`cluster-secret`**

| Variable | Description |
|---|---|
| `name` | cluster name |
| `namenormalized` | cluster name (replacing underscore (_) with hyphen) |
| `server` | sever URL |
| `metadata.labels.key` | secret labels |
| `metadata.annotations.key` | secret annotations |

- Supports `matchLabels` and `matchExpression` selectors for conditioning.
- You can give any valid custom key value pairs under **`spec.generators[].clusters.values`**
- **Applicable for deploying on more than one cluster**

##### Git Generator

- Generates parameters based on files or folders that are contained within the Git repository
- Files containing JSON values will be parsed and converted into template parameters.
- **Applicable for getting values from a remote file**

##### Matrix Generator

- Combines the parameters generated via two other generators.
- If two key have same name in different generators, then application is not created and give errors as "found duplicate key path with different value"
- **Applicable for combining any two generators**

##### Merge Generator

- Combines parameters produced by first generator with matching parameter set produced by following generators
- Appropriate when parameters require overwriting
- This is same as **Left Join in SQL**. Replace the matching values from the right-sided (new) values.
- If 2 generators define the same key, the value from first generator is kept.
- Key defined in `mergeKeys[]` must exist in every generators
- **Applicable for combining any number of generators**

##### Pull Request Generator

- Used for any Kustomize workflow requiring PR testing
- Make sure that new branch name is contained of lowercase letters
- Provides PR specific parameters like:

  | Variable | Description |
  |---|---|
  | branch | Name of the branch of the PR head |
  | target_branch | Name of the target branch of the PR |
  | head_sha | SHA of the head of PR |
  | author | Creator of PR |
  | number | ID number of PR |

- **Applicable for testing PR of manifest changes**

##### Cluster Decision Resource Generator

- To deploy Kustomize applications to clusters based on external resource definitions rather than static cluster registration
- **Applicable for complex cluster selection logic beyond simple labels**

##### Plugin Generator

- Allows custom generator logic through external plugins that can fetch parameters from any source
- **Applicable only when built-in generators are insufficient to your usecase**

##### SCM Generator

- Discover repositories from any SCM providers, generate applications for repositories matching specific criteria
- Uses an API of SCM (e.x. GitHub) to discover repositories. Not use ArgoCD repo server for scan
- **Applicable for multiple repositories resides in multiple organisarion**

Template variables

| Variable | Description |
|---|---|
| url | Repo URL |
| repository | Repo name |
| organization | Org name |
| branch | Branch name |
| branchNormalized | Branch name sanitized for Kubernetes |

### Template - Utilising generated parameters

- This section utilise the values generated via **Generators** to create Applications
- This section is common for all Applications which are going to generate

See examples of ApplicationSet under **`applicationset`** directory

### Prevent Application's child resources from being deleted, when the parent Application is deleted

By default, when an Application resource is deleted by the ApplicationSet controller, all of the child resources of the Application will be deleted as well (such as, all of the Application's Deployments, Services, etc).

To prevent an Application's child resources from being deleted when the parent Application is deleted, add the preserveResourcesOnDeletion: true field to the syncPolicy of the ApplicationSet:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
spec:
    syncPolicy:
        preserveResourcesOnDeletion: true
```

### Prevent deletion of generated Application

Deletion of ApplicationSet does not delete the generated applications

```yaml
finalizers:
  - resources-finalizer.argocd.argoproj.io
```

## Context Switching (Troubleshooting)

I accidently hit `argocd login cd.argoproj.io --core`. The context is changed to `kubernetes` service located inside `default` namespace. I want to direct it to `argocd-server` back.

This error means your Argo CD CLI currently has **no saved contexts at all**, and your last `argocd login` is still “hanging” (likely waiting for input or blocked on network).

### Short answer

```bash
# Context before hitting command
argocd@argocd-server-bd4967f8f-vh5sm:~$ argocd context
CURRENT  NAME                      SERVER
         kubernetes                kubernetes
*        argocd-server.argocd.svc  argocd-server.argocd.svc

# Accidently hitted!!!!!
argocd@argocd-server-bd4967f8f-vh5sm:~$ argocd login --core
Context 'kubernetes' updated

# Get context
argocd@argocd-server-bd4967f8f-vh5sm:~$ argocd context
CURRENT  NAME                      SERVER
*        kubernetes                kubernetes
         argocd-server.argocd.svc  argocd-server.argocd.svc

# Change context back to argocd-server
argocd@argocd-server-bd4967f8f-vh5sm:~$ argocd login argocd-server.argocd.svc --username admin --loglevel debug
WARNING: server certificate had error: error creating connection: tls: failed to verify certificate: x509: certificate is not valid for any names, but wanted to match argocd-server.argocd.svc. Proceed insecurely (y/n)? y
Password:
'admin:login' logged in successfully
Context 'argocd-server.argocd.svc' updated
```

Let’s understand this step by step.

### 1. Stop the stuck `argocd login`

First, make sure the hanging login command is really stopped:

- In that terminal, press `Ctrl + C` to abort the running `argocd login`.
- If it still seems stuck, close that terminal session and open a new one.

You must have a free shell before continuing.

---

### 2. Understand what `--core` did

Running:

```bash
argocd login cd.argoproj.io --core
```

does **not** write a normal context to `~/.config/argocd/config`.
With `--core`, the CLI talks directly to the in‑cluster service via Kubernetes and **skips** the regular login/config mechanism.

That’s why `argocd context` now says:

```text
No contexts defined in /home/argocd/.config/argocd/config
```

This is expected: you currently have **no non-core contexts configured**.

---

### 3. Recreate a normal context by logging in again (without `--core`)

You simply need to run a **fresh login** to your real `argocd-server` endpoint. That will recreate the config file and context.

#### 3.1. Decide how you reach Argo CD

Use whichever of these matches your setup:

1. **Port‑forward to argocd-server**

   ```bash
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```

   Then the Argo CD URL is: `https://localhost:8080`

2. **Ingress / LoadBalancer / external URL**

   For example: `https://argocd.example.com`

Use whatever URL you usually open in your browser for the Argo CD UI.

---

#### 3.2. Run `argocd login` normally

Examples you can adapt:

**A. Using port‑forward (common for local clusters):**

1. In _terminal 1_:

   ```bash
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```

2. In _terminal 2_:

   ```bash
   argocd login localhost:8080 \
     --username admin \
     --password <your-password> \
     --grpc-web \
     --insecure
   ```

   - Add `--grpc-web` if you’re going through an HTTPS reverse proxy or port‑forward.
   - Add `--insecure` if you’re using self‑signed certs or plain HTTP.

**B. Using an external hostname (with proper TLS):**

```bash
argocd login argocd.example.com \
  --username admin \
  --password <your-password>
```

You can also use SSO or a token if that’s how you normally authenticate:

```bash
argocd login argocd.example.com --sso
# or
argocd login argocd.example.com --auth-token <token>
```

After a successful login, the CLI will:

- Create/update `~/.config/argocd/config`
- Add a context for your server (e.g. `argocd.example.com` or `localhost:8080`)
- Set it as the **current** context

---

### 4. Verify that the context is back

Now run:

```bash
argocd context
```

You should **no longer** see the fatal error. Instead, you should see something like:

```text
SERVER               NAME          USER     STATUS
argocd.example.com   argocd        admin    logged in
* argocd.example.com
```

(or `localhost:8080`, etc.)

This confirms your CLI is now pointed back to `argocd-server`.

---

### 5. If the `argocd login` command hangs again

If you re‑run `argocd login` and the terminal “hangs”:

1. **Check if it’s waiting for a password / input**
   - For interactive mode (no `--password`), it may just be waiting for you to type the password (it won’t echo characters).
   - Try typing the password and pressing Enter.

2. **Add `--loglevel debug`** to see what it’s doing:

   ```bash
   argocd login argocd.example.com \
     --username admin \
     --password <pwd> \
     --loglevel debug
   ```

3. **Network / DNS issues**
   If the hostname is wrong or unreachable, it can look “stuck”.
   - Try `curl https://argocd.example.com` or `curl https://localhost:8080` from the same terminal.
   - If that fails, fix port‑forwarding / networking first.

---

### 6. Optional: clear any broken config

If you suspect your config is corrupted, you can remove it and start fresh:

```bash
rm -f /home/argocd/.config/argocd/config
argocd login <your-argocd-server-url> ...
```

This forces `argocd` to recreate the config with just your new context.

---

#### Summary

- `--core` does not create a normal CLI context; hence `No contexts defined` is expected.
- Stop the stuck login (`Ctrl + C`), then run a **new** `argocd login <your-server> ...` **without** `--core`.
- After a successful login, `argocd context` will show your `argocd-server` endpoint again.

If you tell me exactly how you normally access Argo CD (e.g., the URL in your browser or your `kubectl port-forward` command) and what auth method you use (admin/password, SSO, token), I can give you the exact `argocd login` line to paste.

## Rollouts

1. Install a rollout controller and Rollout Kubetl plugin.

    ```bash
    kubectl create namespace argo-rollouts
    kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
    ```

    - Install `Argo Rollouts Kubectl Plugin` - to visualize the Rollouts(ReplicaSets, Pods, AnalysisRuns).

    ```bash
    curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
    chmod +x ./kubectl-argo-rollouts-linux-amd64
    sudo mv ./kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts-linux-amd64
    kubectl argo rollouts version
    ```

2. Deploy a rollout.

    Deployment strategy Blueprint:

    ```yaml
    spec:
      replicas: 5
      strategy:
        canary:
          steps:
          - setWeight: 20 # sends 20% of traffic to the canary followed by a manual promotion.
          - pause: {}
          # finally gradual automated traffic increases for the remainder of the upgrade.
          - setWeight: 40
          - pause: {duration: 10}
          - setWeight: 60
          - pause: {duration: 10}
          - setWeight: 80
          - pause: {duration: 10}
    ```

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-rollouts/master/docs/getting-started/basic/rollout.yaml
    kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-rollouts/master/docs/getting-started/basic/service.yaml
    ```

3. Monitor rollouts.

    ```bash
    kubectl argo rollouts get rollout rollouts-demo --watch
    ```

4. Update a rollout just as we do with `Deployments`, any change to the Pod template field (`spec.template`) results in a new version (i.e. ReplicaSet) to be deployed.

    - Update the rollouts-demo Rollout with the "yellow" version of the container.

    ```bash
    kubectl argo rollouts set image rollouts-demo rollouts-demo=argoproj/rollouts-demo:yellow
    ```

    - Monitor rollout that it sets a 20% traffic weight to the canary, and pauses the rollout indefinitely until user action is taken to **unpause/promote** the rollout.

    ```bash
    kubectl argo rollouts get rollout rollouts-demo --watch
    ```

5. Promote a rollout.

    ```bash
    kubectl argo rollouts promote rollouts-demo
    ```

    - After promotion, rollout will proceed to execute remaining pods on a newer version.

6. Abort a rollout.

    - First deploy new version of the container image to `red` and make rollout `paused` again.

    ```bash
    kubectl argo rollouts set image rollout-demo rollouts-demo=argoproj/rollouts-demo:red
    ```

    - Abort the update, so it falls back to the `stable` version. (in yellow)

    ```bash
    kubectl argo rollouts abort rollout-demo
    ```

    - The rollout is considered as `Degraded`, since `red` image is not the version which is actually running.
    - In order to make it `Healthy` again, change the desired state back to the `yellow` version.

    ```bash
    kubectl argo rollouts set image rollouts-demo rollouts-demo=argoproj/rollouts-demo:yellow
    ```

    - When a Rollout has not yet reached its desired state (e.g. it was aborted, or in the middle of an update), and the stable manifest were re-applied, the Rollout detects this as a rollback and not a update, and will fast-track the deployment of the stable ReplicaSet by skipping analysis, and the steps.

Annotate resource(s) with:

- `argocd.argoproj.io/sync-options: Prune=false` - to prevent from being delete by **syncPolicy.automated.prune**.
- `argocd.argoproj.io/sync-options: Validate=false` - to disable schema validation of resource, silently dropping any unknown or duplicate fields.
  - Similar to `kubectl apply -f resource.yaml --validate='ignore'`.
- `argocd.argoproj.io/sync-options: Delete=false` - to retain resources even after application is deleted. (e.g. PersistentVolumeClaim)
- `argocd.argoproj.io/sync-options: Delete=confirm` - to require manual confirmation before deletion.
  - To confirm the deletion, annotate the application with `argocd.argoproj.io/deletion-approved: ISO-Timestamp`

## ArgoCD Hooks - Run Kubernetes jobs around the ArgoCD application sync

1. `PreSync` - To deploy before `sync` phase. e.x. Database healthcheck jobs, database migration job, etc.

    - ArgoCD will run this `pre-sync` phase first, and once pre-sync phase completes, all the resource of the phase becomes healthy. The `sync` phase will be run and deploy all the resources.

2. `Sync` (default) - The phase when actual resources(deployments, services, service accounts, etc.) are going to deploy in a cluster.

3. `PostSync` - To send notification for application health, sync status.

    - This phase will run only when the `sync` phase is healthy and completed, otherwise won't.

4. `SyncFail` - Runs when `Sync` phase results in failure.

You can create and annotate Kubernetes Job with `argocd.argoproj.io/hook: HookName` to run job in given phases.

- E.x. `argocd.argoproj.io/hook: PreSync` for pre-sync hook.

Make sure that the job is stored on the **same path of the application source**. (Git repository path)

The jobs will run according to the sync-phase of your application.

You can see execution of hook in application **SYNC DETAILS** in steps.

### Hook Deletion policy - Delete hook immediately

- `HookSucceeded` - Hook resource is deleted after a hook succeed. (e.x. Delete `PreSync` Jobs after **Healthy** status)
- `HookFailed` - Hook resource is deleted after a hook failed.
- `BeforeHookCreation` - Any existing hook is deleted before any new one is created. Default Hook deletion policy.

To apply deletion policy, annotate the hook-job with `argocd.argoproj.io/hook-delete-policy: <Deletion-Policy>`

- E.x. `argocd.argoproj.io/hook-delete-policy: HookSucceeded` for deletion of succeeded hook.

## Create resources in order

- You can create order for scheduling resources based on your priority in ArgoCD (e.x. Creating service before deployment).

- Just annotate your resource with `argocd.argoproj.io/sync-wave: "2"`. By default, all resources have priority set to '0'.

- The priority is considered as **High to Low**. (Resource with smaller value has high priority).

- If all resource has same priority, it is created on **`Kind`** order [more info](https://github.com/argoproj/argo-cd/blob/master/gitops-engine/pkg/sync/sync_tasks.go#L26).

### Priorities

| Order | Reference |
| - | - |
| 1 | By Phase (PreSync, PostSync, ...) |
| 2 | By SyncWave (-2, 0, 4, ...) |
| 3 | By Kind (ServiceAccount, Service, ...) |
| 4 | By Name (Same Kind with different name) |

## Configure GitHub Webhook with ArgoCD

- [Reference](https://github.com/argoproj/argo-cd/blob/master/docs/operator-manual/webhook.md)

1. Navigate to the **Organization's settings -> Webhook**. Click **Add Webhhok**
2. Put ArgoCD webhook endpoint in Payload URL (e.x. <https://argocd.example.com/api/webhook>)
3. Choose content type as `application/json`
4. Decide webhook secret and put inside `secret/argocd-secret`

    ```yaml
    stringData:
        webhook.github.secret: SECRET
    ```

    OR under `configs.secret.githubSecret` inside `value.yaml`.

    After saving, the changes should take effect automatically. No pod restart required.
5. Go back to webhook settings in GitHub
6. Enable SSL Verification
7. Decide events to trigger webhook (e.x. **Push**)
8. Mark Active to enable webhook
9. Click Add webhook to create webhook successfully
10. Test webhook by pushing changes in repo

For disabling SSL verification, you have to change in `configmap/argocd-cmd-params-cm` in argocd namespace

```bash
kubectl patch cm argocd-cmd-params-cm -n argocd --type merge -p '{"data": {"server.insecure": "true"}}'
```

## Authenticating with OAuth apps in GitHub

1. Create Oauth App under Github Organization
2. Navigate to `Developer Settings -> OAuth Apps`
3. Click on "New OAuth App"
4. Assign **Application name** (e.x. argocd)
    - Provide **Homepage URL** (e.x. <https://argocd.example.com>)
    - Provide **Callback URL** (e.x. <https://argocd.example.com/api/dex/callback>)
5. Click on "Register Application"
6. After successful creation
    - There will be **Client ID** generated
    - Click on "Genereate a new Client Secrets" to generate a **Client Secret**
    - Store **Client Secrets** and **Client ID** in your space for configuring in ArgoCD later
7. Click on "Update Application" to complete the process of OAuth App
8. After creating OAuth app, Follow below steps in Kubernetes cluster where ArgoCD is deployed

- Via helm chart's values.yaml

    ```yaml
    config:
        cm:
          dex.config: |
            connectors:
                - type: github
                  id: github
                  name: GitHub
                  config:
                    clientID: YOUR-CLIENT-ID
                    clientSecret: YOUR-CLIENT-SECRET
                    orgs:
                      - name: your-github-org-name
                        teams:
                        - team-infra
                        - team-dev
                        - team-admin
    ```

> OR

- Via `configmap/argocd-cm`
- Add `data.dex.config` & `data.url` as following:

    ```yaml
    apiVersion: v1
    data:
        admin.enabled: "true"
        application.sync.impersonation.enabled: "false"
        ...
        dex.config: |
            connectors:
            - type: github
              id: github
              name: GitHub
              config:
                clientID: Ov23linEEEBbioJu7zoc
                clientSecret: c09aaa16e4faa158103f2132dd19947e9f001017
                orgs:
                  - name: manavnmodi
                    teams:
                    - devops
        ...
        statusbadge.enabled: "false"
        timeout.hard.reconciliation: 0s
        timeout.reconciliation: 180s
        url: <https://argocd.example.com>
    kind: ConfigMap
    metadata:
    annotations:
        meta.helm.sh/release-name: argocd
        meta.helm.sh/release-namespace: argocd
    labels:
        app.kubernetes.io/component: server
        app.kubernetes.io/instance: argocd
        app.kubernetes.io/managed-by: Helm
        app.kubernetes.io/name: argocd-cm
        app.kubernetes.io/part-of: argocd
        app.kubernetes.io/version: v3.2.3
        helm.sh/chart: argo-cd-9.2.4
    name: argocd-cm
    namespace: argocd
    ```

## GitHub Authorization with GitHub App

1. Go to `Organization Settings->Developer Settings->Github Apps`
2. Click on "New GitHub App"
    - Provide decided **GitHub App name**
    - Provide ArgoCD Homepage URL in **Home Page URL** (e.x. <https://argocd.example.com/>)
    - Provide Callback URL in **Callback URL** to redirect after successful authorization (e.x. <https://argocd.example.com/>)

3. Mark webhook **Active** and Provide ArgoCD webhook URL (e.x. <https://argocd.example.com/api/webhook>)
4. Provide decided **Webhook secret**
5. Enable **SSL verification**
6. Scroll down and select **Only on this account** to allow this GitHub App to be installed on this organization only
7. Click on "Create GitHub App" to create app
8. After the creation of app, there will be **App ID** & **Client ID** generated. Store and keep both to your local space
9. Generate a new client secret. Store and keep to your local space
10. You need a private key to sign access token requests
    - Click on Generate a private key
    - Download this key

11. Navigate to **Permissions & events** from the sidebar
12. Give Required Permission & Events For ArgoCD
    - Repository Persmissions:

        | Resource | Permission |
        | - | - |
        | Contents | Read Only |
        | Pull Requests | Read Only |

    - Organization Permission

        | Resource | Permission |
        | - | - |
        | Members | Read Only |

13. Subscribe to **Push** Events for Webhook
14. Click "Save Changes"
15. After completing these steps, Install this Github App under your Organization for **All repositories**
16. After GitHub App installation, go to <https://github.com/organizations/your-org/settings/installations>
17. Click "Configure" for your GitHub app
18. Copy URL of opened page suffixed with **appInstallationID**. Store and Keep that **appInstallationID**
19. After all configuration done in GitHub, configure ArgoCD by creating a secret labelled with `argocd.argoproj.io/secret-type: repo-creds`
in secret under `stringData`:
    - `url` - organization URL
    - `githubAppID` - get appID we get above
    - `githubAppInstallationID` - get appInstallationID we get above
    - `githubAppPrivateKey` - download private key generated at creation time of github app

    Or put above values in helm `values.yaml` under `configs.credentialTemplates.<your-appname>` (i.e. my-github-app)

    ```yaml
    configs:
        credentialTemplates:
            my-github-app:
                url: ""
                githubAppID: ""
                ...
    ```

## Configuration tweaks

### Repo Server

- [Reference](https://github.com/argoproj/argo-cd/blob/master/docs/operator-manual/high_availability.md#argocd-repo-server)

#### Reduce cache expiration time

- Argo CD assumes by default that manifests only change when the repo changes, so it caches the generated manifests (for `24h` by default). To reduce cache expiration time,
  - Supply argument `--repo-cache-expiration <duration>` to the `repo-server`, Or
  - Supply configuration `reposerver.repo.cache.expiration: <duration>` in `configmap/argocd-cmd-params-cm`.

  See **ARGOCD_REPO_CACHE_EXPIRATION** inside repo-server deployment.

#### Git related configuration

| Configuration | ENV | Purpose | Default |
|---|---|---|---|
| reposerver.parallelism.limit | ARGOCD_REPO_SERVER_PARALLELISM_LIMIT | Limit on number of concurrent manifests generate requests | "0" (No limit) |
| reposerver.git.lsremote.parallelism.limit | ARGOCD_GIT_LS_REMOTE_PARALLELISM_LIMIT | Number of concurrent git ls-remote requests | "0" (No limit) |
| reposerver.git.request.timeout | ARGOCD_GIT_REQUEST_TIMEOUT | Git requests timeout for auth, clone, fetch, ls-remote | "15s" |

---

### Application Controller

#### Application Processing Queues

Each controller replica processes applications using two separate queues to process application reconciliation and app syncing

| Types of Queue | Purpose | Running Frequency | Argument to set | Default Value | Preferred value (1000 applications) |
|---|---|---|---|---|---|
| Status Queue | To check application health status. | Very frequently (ms) | --status-processors | 20 | 50 |
| Operation Queue | Application operations. Sync, Delete, Rollback | Runs slower (seconds) | --operation-processors | 10 | 25 |

---

#### Cluster update info timeout

- By default, the controller will update the cluster information every 10 seconds.

  Set `ARGO_CD_UPDATE_CLUSTER_INFO_TIMEOUT` to increase the timeout (in seconds) while in case of network issues

---

#### Controller Sharding (Alpha) [Configuration Reference](https://argo-cd.readthedocs.io/en/stable/operator-manual/feature-maturity/#configuration)

If ArgoCD manages many clusters or applications, the single controller may consume large amounts of memory.

  To solve this, you can split workload across multiple controllers.
  Increase **controller replica** to 2 OR set **ARGOCD_CONTROLLER_REPLICAS** to 2

##### Sharding Distribution Methods

| Method | Description | Balancing | Value |
|---|---|---|---|
| Legacy Mode | Uses UID-based distribution | Not evenly balanced | legacy |
| Round-Robin | Equal distribution across all shards | Distributes clusters evenly | round-robin |
| Consistent Hashing | Minimizes reshuffling when add/remove shards | Provides balanced distribution | consistent-hashing |

Configured in **argocd-cmd-params-cm** configmap under `controller.sharding.algorithm` OR Setting ENV in Controller `ARGOCD_CONTROLLER_SHARDING_ALGORITHM`

###### Manually/Forcefully Assigning Clusters to Shards

Set shard value in the cluster secret

```yaml
stringData:
  shard: 1
```

---

#### Cluster Cache Optimization Settings

| Setting | Reason | ENV Configuration | Default |
|---|---|---|---|
| Cache Page Size | The LIST operation is performed in pagination. Number of resources a single page contains | ARGOCD_CLUSTER_CACHE_LIST_PAGE_SIZE | 500 |
| Cache Page Buffer | Number of pages to buffer when making a K8s query to LIST resources. Helps when clusters contain very large numbers of resources. | ARGOCD_CLUSTER_CACHE_LIST_PAGE_BUFFER_SIZE | 1 |
| Event Batch Processing | To collect/process Kubernetes events in batches. Reduces controller overload. | ARGOCD_CLUSTER_CACHE_BATCH_EVENTS_PROCESSING | TRUE |
| Event Processing Interval | Controlling the interval for processing events in a batch. Used only when batch event processing is enabled. | ARGOCD_CLUSTER_CACHE_EVENTS_PROCESSING_INTERVAL | 100ms |
| Split Application Resource Tree in multiple Redis key | Max number of resources stored in one Redis key. Split application tree into multiple keys. To reduce the traffic between the controller and Redis. | ARGOCD_APPLICATION_TREE_SHARD_SIZE | 0 |

ArgoCD fetches one page (500 resources), processes it, then fetches the next page, and so on. So If we have 10,000 resources: 500 page size * 20 buffer

---

#### Client connection settings

- [Reference](https://argo-cd.readthedocs.io/en/latest/operator-manual/argocd-cmd-params-cm-yaml/)

| Configuration | ENV | Purpose | Default |
|---|---|---|---|
| controller.k8s.client.qps | ARGOCD_K8S_CLIENT_QPS | QPS limit for K8s API client request. Rate limit for the K8s API from the controller | 50 |
| controller.k8s.client.burst | ARGOCD_K8S_CLIENT_BURST | Burst value for K8s API client request. Exceed the QPS temporarily when there's a sudden need for more API requests | 100 |
| controller.k8s.client.max.idle.connections | ARGOCD_K8S_CLIENT_MAX_IDLE_CONNECTIONS | Maximum number of idle connections in K8s client. Max no. of connections kept in the connection pool | 500 |

---

#### Network Timeout settings

| Configuration | ENV | Purpose | Default |
|---|---|---|---|
| controller.k8s.tcp.timeout | ARGOCD_K8S_TCP_TIMEOUT | TCP connection timeout for K8s client. Send keep-alive packets to maintain connection | 30s |
| controller.k8s.tcp.keepalive | ARGOCD_K8S_TCP_KEEPALIVE | TCP keep-alive interval for K8s client | 30s |
| controller.k8s.tls.handshake.timeout | ARGOCD_K8S_TLS_HANDSHAKE_TIMEOUT | TCP handshake timeout for K8s client | 10s |
| controller.k8s.tcp.idle.timeout | ARGOCD_K8S_TCP_IDLE_TIMEOUT | TCP idle timeout for K8s client. Connection is terminated after 5min of inactivity | 5m |

---

#### Retry Configuration

| Configuration | ENV | Purpose | Default |
|---|---|---|---|
| controller.k8sclient.retry.max | ARGOCD_K8SCLIENT_RETRY_MAX | Max number of retry attempts for each request | 5 |
| controller.k8sclient.retry.base.backoff | ARGOCD_K8SCLIENT_RETRY_BASE_BACKOFF | Initial backoff delay(ms) first retry attempt. Subsequent retries will double this backoff time | 100 |

---

#### Timeouts

| Configuration | ENV | Purpose | Default |
|---|---|---|---|
| controller.repo.server.timeout.seconds | ARGOCD_APPLICATION_CONTROLLER_REPO_SERVER_TIMEOUT_SECONDS | Manifest generation timeout | 60 |
| controller.self.heal.timeout.seconds | ARGOCD_APPLICATION_CONTROLLER_SELF_HEAL_TIMEOUT_SECONDS | Timeout between application self heal attempts | 0 |

---

### Key Improvements

#### 1. **Pagination and Buffering**

For large clusters, use pagination to avoid etcd compaction issues:

- `ARGOCD_CLUSTER_CACHE_LIST_PAGE_SIZE`: Controls page size (default: 500)
- `ARGOCD_CLUSTER_CACHE_LIST_PAGE_BUFFER_SIZE`: Buffers pages in memory

#### 2. **Semaphore Control**

Limit concurrent list operations to prevent memory spikes:

```go
clusterCacheListSemaphoreSize int64 = 50
```

#### 3. **Batch Event Processing**

Process events in batches to reduce lock contention:

```yaml
controller.cluster.cache.batch.events.processing: "true"
controller.cluster.cache.events.processing.interval: "100ms"
```

#### 4. **RBAC Respect Mode**

Automatically skip resources without permissions:

```yaml
resource.respectRBAC: "strict"  # or "normal"
```

#### 5. **Retry Logic**

Configure retry behavior for failed operations:

- `ARGOCD_CLUSTER_CACHE_ATTEMPT_LIMIT`: Number of retries
- `ARGOCD_CLUSTER_CACHE_RETRY_USE_BACKOFF`: Enable backoff strategy

#### 6. **Resource Exclusions**

Pre-filter problematic resources:

```yaml
resource.exclusions: |
  - apiGroups: ["projectcalico.org"]
    kinds: ["BGPFilter"]
```

#### 7. **Sharding**

Distribute clusters across multiple controllers:

```yaml
controller.sharding.algorithm: "consistent-hashing"
```

#### Notes

- The actual sequence includes OpenAPI schema loading for proper resource conversion
- Permission checks happen reactively after failed list operations
- Watch connections restart every 10 minutes by default
- Cache resyncs every 12 hours to ensure consistency

#### Citations

**File:** controller/cache/cache.go (L97-102)

```go
// The default limit of 50 is chosen based on experiments.
clusterCacheListSemaphoreSize int64 = 50

// clusterCacheListPageSize is the page size when performing K8s list requests.
// 500 is equal to kubectl's size
clusterCacheListPageSize int64 = 500
```

**File:** controller/cache/cache.go (L107-112)

```go
// clusterCacheRetryLimit sets a retry limit for failed requests during cluster cache sync
// If set to 1, retries are disabled.
clusterCacheAttemptLimit int32 = 1

// clusterCacheRetryUseBackoff specifies whether to use a backoff strategy on cluster cache sync, if retry is enabled
clusterCacheRetryUseBackoff = false
```

**File:** controller/cache/cache.go (L114-118)

```go
// clusterCacheBatchEventsProcessing specifies whether to enable batch events processing
clusterCacheBatchEventsProcessing = false

// clusterCacheEventsProcessingInterval specifies the interval between processing events when BatchEventsProcessing is enabled
clusterCacheEventsProcessingInterval = 100 * time.Millisecond
```

**File:** docs/operator-manual/high_availability.md (L106-140)

```markdown
* If the controller is managing too many clusters and uses too much memory then you can shard clusters across multiple
  controller replicas. To enable sharding, increase the number of replicas in `argocd-application-controller`
  `StatefulSet`
  and repeat the number of replicas in the `ARGOCD_CONTROLLER_REPLICAS` environment variable. The strategic merge patch
  below demonstrates changes required to configure two controller replicas.

* By default, the controller will update the cluster information every 10 seconds. If there is a problem with your
  cluster network environment that is causing the update time to take a long time, you can try modifying the environment
  variable `ARGO_CD_UPDATE_CLUSTER_INFO_TIMEOUT` to increase the timeout (the unit is seconds).

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: argocd-application-controller
spec:
  replicas: 2
  template:
    spec:
      containers:
        - name: argocd-application-controller
          env:
            - name: ARGOCD_CONTROLLER_REPLICAS
              value: "2"
```

- In order to manually set the cluster's shard number, specify the optional `shard` property when creating a cluster. If
  not specified, it will be calculated on the fly by the application controller.
- The shard distribution algorithm of the `argocd-application-controller` can be set by using the `--sharding-method`
  parameter. Supported sharding methods are:
  - `legacy` mode uses an `uid` based distribution (non-uniform).
  - `round-robin` uses an equal distribution across all shards.
  - `consistent-hashing` uses the consistent hashing with bounded loads algorithm which tends to equal distribution
      and also reduces cluster or application reshuffling in case of additions or removals of shards or clusters.

**File:** docs/operator-manual/high_availability.md (L184-194)

```markdown
* `ARGOCD_CLUSTER_CACHE_LIST_PAGE_BUFFER_SIZE` - environment variable controlling the number of pages the controller
  buffers in memory when performing a list operation against the K8s api server while syncing the cluster cache. This
  is useful when the cluster contains a large number of resources and cluster sync times exceed the default etcd
  compaction interval timeout. In this scenario, when attempting to sync the cluster cache, the application controller
  may throw an error that the `continue parameter is too old to display a consistent list result`. Setting a higher
  value for this environment variable configures the controller with a larger buffer in which to store pre-fetched
  pages which are processed asynchronously, increasing the likelihood that all pages have been pulled before the etcd
  compaction interval timeout expires. In the most extreme case, operators can set this value such that
  `ARGOCD_CLUSTER_CACHE_LIST_PAGE_SIZE * ARGOCD_CLUSTER_CACHE_LIST_PAGE_BUFFER_SIZE` exceeds the largest resource
  count (grouped by k8s api version, the granule of parallelism for list operations). In this case, all resources will
  be buffered in memory -- no api server request will be blocked by processing.
```

## Disaster Recovery

You can use `argocd admin` to import and export all Argo CD data.

Exported Data contains: (Applications, ApplicationSets, Configmaps, Secrets, Projects, etc...)

- To export all ArgoCD data to a file: `argocd admin export > argo-data.yaml`
- To import all ArgoCD data from a file: `argocd admin import - < argo-data.yaml`

## Auditing in ArgoCD

> **"Git commit history provides a natural audit log of what changes were made to application configuration, when they were made, and by whom. To complement the Git revision history, Argo CD emits Kubernetes Events of application activity, indicating the responsible actor when applicable."**
~ [Documentation](https://argo-cd.readthedocs.io/en/stable/operator-manual/security/#auditing)

View event in Kubernetes with:

```bash
kubectl get events -n argocd --field-selector involvedObject.kind=Application
```

Output similar to:

```text
NAMESPACE  LAST SEEN  TYPE    REASON           OBJECT                        MESSAGE
argocd     13m        Normal  ResourceDeleted  application/my-kustomize-app  admin deleted application
argocd     13m        Normal  ResourceUpdated  application/my-kustomize-app  Updated health status: Healthy -> Progressing
argocd     13m        Normal  ResourceUpdated  application/my-kustomize-app  Updated health status: Progressing -> Healthy
```

### API Endpoints for Auditing

There are API endpoints of ArgoCD which give response of resource events. You can bind these endpoints to your logging system to aggregate event logs in one place.

| Endpoint | Response |
|---|---|
| **/api/v1/applications/nodejs/events**               | events of given application         |
| **/api/v1/projects/tax/events**                      | events of given project             |
| **/api/v1/stream/applications**                      | stream of application change events |
| **/api/v1/stream/applications/nodejs/resource-tree** | stream of application resource tree |

## ArgoCD API Exposure

ArgoCD provide API endpoints to make it accessible. All endpoints with its schema are listed is Swagger UI at `argocd.example.com/swagger-ui`.

### Generate session token

```bash
curl -H "Content-Type: application/json" argocd.example.com/api/v1/session -d $'{"username":"user","password":"password"}' | jq .token
curl -H --insecure "Content-Type: application/json" http://172.20.0.3:30080/api/v1/session -d $'{"username":"admin","password":"admin123"}' | jq .token
curl -H "Content-Type: application/json" argocd-server.argocd.svc/api/v1/session -d $'{"username":"admin","password":"admin@1234"}'
```

Request Response:

```json
{"token":"GENERATED-SESSION-TOKEN-VALID-FOR-24H"}
```

### Session Error as no bearer token is provided

```bash
curl https://argocd.example.com/api/v1/applications
```

Request Response:

```json
{"error":"no session information","code":16,"message":"no session information"}
```

### ArgoCD Projects

#### Get ArgoCD Projects

```bash
curl -H "Authorization: Bearer <session-token>" argocd.example.com/api/v1/projects
```

Request Response:

```json
{
  "metadata": { "resourceVersion": "10710177" },
  "items": [
    {
      "metadata": {
        "name": "default",
        "namespace": "argocd",
        "uid": "419e01d3-d8f0-44b6-af39-40624c32778d",
        "resourceVersion": "5967078",
        "generation": 10,
        "creationTimestamp": "2026-01-02T07:25:55Z",
        "managedFields": [
          {
            "manager": "argocd-server",
            "operation": "Update",
            "apiVersion": "argoproj.io/v1alpha1",
            "time": "2026-01-07T07:05:15Z",
            "fieldsType": "FieldsV1",
            "fieldsV1": {
              "f:spec": {
                ".": {},
                "f:clusterResourceWhitelist": {},
                "f:sourceRepos": {}
              },
              "f:status": {}
            }
          },
          {
            "manager": "kubectl-edit",
            "operation": "Update",
            "apiVersion": "argoproj.io/v1alpha1",
            "time": "2026-01-07T07:09:28Z",
            "fieldsType": "FieldsV1",
            "fieldsV1": { "f:spec": { "f:destinations": {} } }
          }
        ]
      },
      "spec": {
        "sourceRepos": ["*"],
        "destinations": [{ "server": "*", "namespace": "*", "name": "*" }],
        "clusterResourceWhitelist": [{ "group": "*", "kind": "*" }]
      },
      "status": {}
    },
    {
      "metadata": {
        "name": "samples",
        "namespace": "argocd",
        "uid": "33aab2ee-d4bd-4d8b-ab89-90f4f7b0145a",
        "resourceVersion": "8014780",
        "generation": 13,
        "creationTimestamp": "2026-01-02T08:37:42Z",
        "annotations": {
          "kubectl.kubernetes.io/last-applied-configuration": "{\"apiVersion\":\"argoproj.io/v1alpha1\",\"kind\":\"AppProject\",\"metadata\":{\"annotations\":{},\"creationTimestamp\":\"2026-01-02T08:37:42Z\",\"generation\":4,\"name\":\"samples\",\"namespace\":\"argocd\",\"resourceVersion\":\"5963511\",\"uid\":\"33aab2ee-d4bd-4d8b-ab89-90f4f7b0145a\"},\"spec\":{\"clusterResourceWhitelist\":[{\"group\":\"*\",\"kind\":\"*\"}],\"description\":\"Experimental space.\",\"destinations\":[{\"name\":\"*\",\"namespace\":\"*\",\"server\":\"*\"}],\"sourceRepos\":[\"*\"],\"syncWindows\":[{\"applications\":[\"application*\"],\"duration\":\"1h\",\"kind\":\"allow\",\"schedule\":\"* * * * *\"}]}}\n"
        },
        "managedFields": [
          {
            "manager": "kubectl-client-side-apply",
            "operation": "Update",
            "apiVersion": "argoproj.io/v1alpha1",
            "time": "2026-02-02T08:28:14Z",
            "fieldsType": "FieldsV1",
            "fieldsV1": {
              "f:metadata": {
                "f:annotations": {
                  ".": {},
                  "f:kubectl.kubernetes.io/last-applied-configuration": {}
                }
              }
            }
          },
          {
            "manager": "argocd-server",
            "operation": "Update",
            "apiVersion": "argoproj.io/v1alpha1",
            "time": "2026-02-02T08:42:49Z",
            "fieldsType": "FieldsV1",
            "fieldsV1": {
              "f:spec": {
                ".": {},
                "f:clusterResourceWhitelist": {},
                "f:description": {},
                "f:destinations": {},
                "f:sourceRepos": {}
              },
              "f:status": {}
            }
          }
        ]
      },
      "spec": {
        "sourceRepos": ["*"],
        "destinations": [{ "server": "*", "namespace": "*", "name": "*" }],
        "description": "Experimental space.",
        "clusterResourceWhitelist": [{ "group": "*", "kind": "*" }]
      },
      "status": {}
    }
  ]
}
```

#### Create an ArgoCD Project

**`create-argocd-project-payload.json`**

```json
{
  "project": {
    "metadata": {
      "name": "project-for-disaster",
      "namespace": "argocd",
      "uid": "f4f07aeb-001d-4950-add0-09de8bf0ef61",
      "generation": 6,
      "creationTimestamp": "2026-01-28T13:29:08Z",
      "managedFields": [
        {
          "manager": "argocd-server",
          "operation": "Update",
          "apiVersion": "argoproj.io/v1alpha1",
          "time": "2026-03-06T08:18:57Z",
          "fieldsType": "FieldsV1",
          "fieldsV1": {
            "f:spec": {
              ".": {},
              "f:clusterResourceWhitelist": {},
              "f:destinations": {}
            },
            "f:status": {}
          }
        }
      ]
    },
    "spec": {
      "destinations": [{ "server": "*", "namespace": "*" }],
      "clusterResourceWhitelist": [{ "group": "*", "kind": "*" }]
    },
    "status": {}
  }
}

```

Create a new project in Failover cluster by passing above JSON payload

```bash
curl -X POST -d @create-argocd-project-payload.json -H "Authorization: Bearer <session-token>" -H "Content-Type: application/json" https://argocd.example.com/api/v1/projects
```

### ArgoCD Applications

#### Get all ArgoCD Applications

```bash
curl -H "Authorization: Bearer <session-token>" https://argocd.example.com/api/v1/applications
```

Request Response:

```json
{
  "metadata": { "resourceVersion": "95396127" },
  "items": [
    {
      "metadata": {
        "name": "nodejs",
        "namespace": "argocd",
        "resourceVersion": "95395092",
        "creationTimestamp": "2026-02-09T09:30:26Z"
      },
      "spec": {
        "source": {
          "repoURL": "https://github.com/argoproj/argocd-example-apps",
          "path": "kustomize-guestbook",
          "targetRevision": "HEAD"
        },
        "destination": {
          "server": "https://kubernetes.default.svc",
          "namespace": "default"
        },
        "project": "default",
        "syncPolicy": { "automated": { "enabled": true } }
      },
      "status": {}
    }
  ]
}
```

#### Create an ArgoCD Application

**`create-argocd-application.json`**

```json
{
  "application": {
    "metadata": {
      "name": "kustomize-prod",
      "namespace": "argocd",
      "uid": "fd8d6686-af1f-4fde-9800-fd8618b66f13",
      "resourceVersion": "95395092",
      "creationTimestamp": "2026-02-09T09:30:26Z"
    },
    "spec": {
      "source": {
        "repoURL": "https://github.com/HarshPanchal18/argocd-application.git",
        "path": "k8s/overlays/production",
        "targetRevision": "HEAD"
      },
      "destination": {
        "server": "https://kubernetes.default.svc",
        "namespace": "default"
      },
      "project": "default",
      "syncPolicy": { "automated": { "enabled": true } }
    },
    "status": {}
  }
}
```

Create a new project in Failover cluster by passing above JSON payload

```bash
curl -X POST -d @create-argocd-application.json -H "Authorization: Bearer <session-token>" -H "Content-Type: application/json" https://argocd.example.com/api/v1/applications
```

### Kubernetes Cluster

#### Get clusters attached in ArgoCD

```bash
curl -H "Authorization: Bearer <session-token>" https://argocd.example.com/api/v1/clusters
```

Request Response:

```json
{
  "metadata": {},
  "items": [
    {
      "server": "https://kubernetes.default.svc",
      "name": "in-cluster",
      "config": { "tlsClientConfig": { "insecure": false } },
      "connectionState": {
        "status": "Unknown",
        "message": "",
        "attemptedAt": "2026-03-12T12:48:11Z"
      },
      "info": {
        "connectionState": {
          "status": "Unknown",
          "message": "",
          "attemptedAt": "2026-03-12T12:48:11Z"
        },
        "cacheInfo": {},
        "applicationsCount": 3
      },
      "-": {}
    }
  ]
}
```

#### Get cluster by server name and server address

```bash
curl -H "Authorization: Bearer <session-token>" https://argocd.example.com/api/v1/clusters?name=<server-name>
curl -H "Authorization: Bearer <session-token>" https://argocd.example.com/api/v1/clusters?server=https://<server-url>
# e.x. curl -H "Authorization: Bearer <session-token>" https://argocd.example.com/api/v1/clusters?server=https://kubernetes.default.svc
```

#### Create a cluster

**`create-cluster.json`**

```json
{
  "server": "https://kubernetes.default.svc",
  "name": "in-clusterr",
  "config": {
    "tlsClientConfig": {
      "insecure": false
    }
  },
  "connectionState": {
    "status": "Successful",
    "message": "",
    "attemptedAt": "2026-03-10T11:44:36Z"
  },
  "serverVersion": "1.34",
  "info": {
    "connectionState": {
      "status": "Successful",
      "message": "",
      "attemptedAt": "2026-03-10T11:44:36Z"
    },
    "serverVersion": "1.34",
    "cacheInfo": {
      "resourcesCount": 3935,
      "apisCount": 217,
      "lastCacheSyncTime": "2026-03-10T08:11:34Z"
    },
    "applicationsCount": 1,
    "apiVersions": [
      "v1",
      "v1/ConfigMap",
      "v1/Endpoints",
      "v1/Event",
      "v1/LimitRange",
      "v1/Namespace",
      "v1/Node",
      "v1/PersistentVolume",
      "v1/PersistentVolumeClaim",
      "v1/Pod",
      "v1/PodTemplate",
      "v1/ReplicationController",
      "v1/ResourceQuota",
      "v1/Secret",
      "v1/Service",
      "v1/ServiceAccount"
      // Include all other api versions...
    ]
  },
  "-": {}
}
```

Create a new cluster by passing above JSON payload

```bash
curl -X POST -d @create-cluster.json -H "Authorization: Bearer <session-token>" -H "Content-Type: application/json" https://argocd.example.com/api/v1/clusters
```

#### Rotate Bearer Token used for a cluster

> Make sure you have permission to perform this task.

```bash
curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <session-token>" https://argocd.example.com/api/v1/clusters/in-cluster/rotate-auth
```

## Rotate Redis Secret

- Delete `argocd-redis` secret in the namespace where Argo CD is installed.

```bash
kubectl delete secret argocd-redis -n <argocd namespace>
```

- If you are running Redis in **HA** mode, restart Redis in HA.

```bash
kubectl rollout restart deployment argocd-redis-ha-haproxy
kubectl rollout restart statefulset argocd-redis-ha-server
```

- If you are running Redis in **non-HA** mode, restart Redis.

```bash
kubectl rollout restart deployment argocd-redis
```

- Restart other components.

```bash
kubectl rollout restart deployment argocd-server argocd-repo-server
kubectl rollout restart statefulset argocd-application-controller
```

## Configuring CMP (Configuration Management Plugin)

Argo CD's "native" config management tools are Helm, Jsonnet, and Kustomize. If you want to use a different config management tool, or if Argo CD's native tool support does not include a feature you need, you might need to turn to a Config Management Plugin (CMP).

The Repository Server is in charge of building Kubernetes manifests based on some source files from a Helm, OCI, or Git repository. When a config management plugin is correctly configured, the repo server may delegate the task of building manifests to the plugin.

- [Documentation Reference](https://argo-cd.readthedocs.io/en/stable/operator-manual/config-management-plugins/)

### Writing CMP Plugin

Plugins will be configured via a ConfigManagementPlugin manifest YAML

Plugin can be configured with below set of values:

| Topic | Description | Requirement |
|---|---|---|
| name              | Plugin Name | required |
| init commands     | Run given commands in source directory before manifest generation | required |
| generate commands | Run given commands in source directory for manifest generation | required |
| version           | Plugin Version | optional |
| file discovery    | Discover file in given path based on pattern | optional |
| parameters        | Build YAML with parameters | optional |

#### E.x. Build timoni bundle through CMP

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ConfigManagementPlugin
metadata:
  name: argo-cmp-timoni
spec:
  init:
    command: []
    args: []
  generate:
    command: ["/bin/sh", "-c"]
    args:
      - |
        /usr/local/bin/timoni build test-app -n beta-app .
```

### Install Plugin using sidecar

1. Create a plugin YAML basedon your build(YAML generation) logic
2. Put inside a runner Docker image (alpine, nginx, etc.). See [Dockerfile](https://github.com/HarshPanchal18/DevOps/tree/main/argocd/config-management-plugin/Dockerfile)
3. Build and Push image into the registry
4. Attach a container of above image under Repository Server deployment at path **spec.template.spec.containers**. See [sidecar.yaml](https://github.com/HarshPanchal18/DevOps/tree/main/argocd/config-management-plugin/sidecar.yaml)
5. Configure required volume under **spec.template.spec.volumes**

    ```yaml
    - emptyDir: {}
      name: cmp-tmp
    - emptyDir: {}
      name: plugins
    - emptyDir: {}
      name: var-files
    ```

6. Set **ARGOCD_ASK_PASS_SOCK** environment variable for `repo-server` container

    ```yaml
      env:
      - name: ARGOCD_ASK_PASS_SOCK
        value: "/var/run/argocd/askpass/reposerver-ask-pass.sock"
    ```

### Configure ENVs for Plugin to generate YAML

1. We can pass Environement Variables in Plugin YAML to support in dynamic values for generating YAML
2. We have to prefix the Environemnt variable with **ARGOCD_ENV** for each decided variables

    E.x. - ArgoCD Application utilising Timoni Plugin with ENVs

    ```yaml
    apiVersion: argoproj.io/v1alpha1
    kind: ConfigManagementPlugin
    metadata:
      name: argo-cmp-timoni
    spec:
      init:
        command: []
        args: []
      generate:
        command: ["/bin/sh", "-c"]
        args:
          - |
            /usr/local/bin/timoni build test-app-${ARGOCD_ENV_APP_ENV} -n beta-app .
    ```

    ```yaml
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: application-timoni
      namespace: argocd
    spec:
      project: samples
      source:
        repoURL: https://github.com/HarshPanchal18/timoni-sample-app
        path: '.'
        targetRevision: HEAD
        plugin:
          name: argo-cmp-timoni-v0.1.1
          env:
            - name: APP_ENV
              value: 'prod'
      destination:
        server: https://kubernetes.default.svc
        namespace: ns-prod
    ```

### Configure Parameters for plugin to generate YAML

1. We can utilise parameters in Plugin YAML to support in dynamic values for generating YAML
2. We have to prefix the Parameter variable with **PARAM_** for each decided field (e.g. **APP_NAMESPACE** will need to be referred as **PARAM_APP_NAMESPACE** in Plugin YAML)

    E.x. - ArgoCD Application utilising Timoni Plugin with Parameters

    ```yaml
    apiVersion: argoproj.io/v1alpha1
    kind: ConfigManagementPlugin
    metadata:
      name: argo-cmp-timoni
    spec:
      init:
        command: []
        args: []
      generate:
        command: ["/bin/sh", "-c"]
        args:
          - |
            /usr/local/bin/timoni build test-app${PARAM_ENVIRONMENT} -n beta-app .
      parameters:
        static:
          - name: environment
            title: "Timoni App Environment"
            required: true
            strings: alpha
    ```

    ```yaml
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: application-timoni
      namespace: argocd
    spec:
      project: samples
      source:
        repoURL: https://github.com/HarshPanchal18/timoni-sample-app
        path: '.'
        targetRevision: HEAD
        plugin:
          name: argo-cmp-timoni-v0.1.1
          parameters:
            - name: environment
              string: prod
      destination:
        server: https://kubernetes.default.svc
        namespace: ns-prod
    ```

### Standard Application Variables can be utilised inside CMP plugin.yaml

These variables are automatically available for your plugin commands to negate mundane tasks:

- `ARGOCD_APP_NAME` - Application name
- `ARGOCD_APP_NAMESPACE` - Application namespace
- `ARGOCD_APP_PROJECT_NAME` - The Project name the application belongs to
- `ARGOCD_APP_REVISION` - Full Git revision
- `ARGOCD_APP_REVISION_SHORT` - Shortened Git revision (7 chars)
- `ARGOCD_APP_REVISION_SHORT_8` - Shortened Git revision (8 chars)
- `ARGOCD_APP_SOURCE_REPO_URL` - The Repository URL
- `ARGOCD_APP_SOURCE_PATH` - The path within the repository
- `ARGOCD_APP_SOURCE_TARGET_REVISION` - The target revision (branch/tag)
- `ARGOCD_APP_PARAMETERS` - JSON string containing application parameters passed to plugins

## Configuring MCP Server for Argo CD in VS Code

```json
{
  "servers": {
    "argocd-mcp": {
      "type": "stdio",
      "command": "npx",
      "args": ["argocd-mcp@latest", "stdio"],
      "env": {
        "ARGOCD_BASE_URL": "ARGO_CD_URL",
        "ARGOCD_API_TOKEN": "SESSION_TOKEN",

        // If running for dev/local cluster
        "ARGOCD_VERIFY_SSL": "false",
        "ARGOCD_INSECURE": "true",
        "NODE_TLS_REJECT_UNAUTHORIZED": "0"
      },
      "capabilities": {
        "serverInfo": true,
        "toolExecution": true
      }
    }
  }
}
```

- [Configure MCP in VS Code](https://code.visualstudio.com/docs/copilot/customization/mcp-servers#_add-an-mcp-server)
- [Official NPM Package](https://www.npmjs.com/package/argocd-mcp)
- [Official GitHub Repo for MCP](https://github.com/argoproj-labs/mcp-for-argocd)
