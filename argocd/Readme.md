# GitOps - A Simple, Consistent, and Secure approach to manage your environments

## Index

- [Problem](#problem)
- [Solution](#solution)
- [Introduction](#argocd---a-declarative-gitops-cd-tool-based-on-kubernetes)
- [Application Restrictions](#restricting-applications-using-projects-in-different-ways)
- [Cluster Management](#cluster-management)
- [Add New Cluster](#add-a-kubernetes-cluster-to-deploy-applications-through-argocd)
- [Local User Management](#local-user-management)
- [Reset Password](#reset-password)
- [RBAC Authorization](#rbac-authorization)
- [Context Switching](#context-switching-troubleshooting)
- [Rollouts](#rollouts)
- [SyncOptions for Application](#sync-options-for-application)
- [ArgoCD Hooks](#argocd-hooks---run-kubernetes-jobs-around-the-argocd-application-sync)
- [Resource creation order](#create-resources-in-order)

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

## Restricting Applications using Projects in different ways

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
        config: |
            {
                "bearerToken": "ENCODED-BEARER-TOKEN",
                "tlsClientConfig": {
                    "insecure": true,
                    "caData": "ENCODED-CA-DATA"
                }
            }
    ```

6. Apply above secret in a clustere where ArgoCD is deployed.
7. After applying this secret, ArgoCD sync target cluster automatically.
8. Check if the target cluster is added successfully into ArgoCD by visiting: <https://argocd.example.com/settings/clusters>

### Important Security Note

- > Handle with care: Anyone with this token has full cluster-admin access to your target cluster.

- > Use the CLI if possible: When you run `argocd cluster add <name>`, the CLI does all of the steps above automatically for you, including generating the token and creating the secret in Argo CD. It is much safer and easier.

## Local User Management

### Create new user

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

## Reset password

```bash
# Generate token
$ htpasswd -nbBC 10 "" admin123 | tr -d ':\n' | sed 's/$2y/$2a/'

# e.x. $2a$10$UAJR/PVjG9UcjVhQSLNike1j9LilJA6vYlJw/yuZ6/kJ3903N/dm6

# Patch secret/argocd-secret to update value
kubectl -n argocd patch secret argocd-secret -p '{"data": {"admin.password": "$2a$10$UAJR/PVjG9UcjVhQSLNike1j9LilJA6vYlJw/yuZ6/kJ3903N/dm6", "admin.passwordMtime": "'$(date +%FT%T%Z | base64)'"}}'

# Restart pod/argocd-server
kubectl -n argocd delete pods -l app.kubernetes.io/name=argocd-server
```

### Reset Admin password

To reset the ArgoCD admin password it is required to delete the values of admin.password and admin.passwordMtime that are stored as K8s secret object argocd-secret in the namespace in which ArgoCD is installed (default argocd)

```bash
$ kubectl patch secret argocd-secret -p '{"data": {"admin.password": null, "admin.passwordMtime": null}}'
- sample output -
secret/argocd-secret patched
```

Restart ArgoCD server to generate the new admin password

```bash
$ kubectl rollout restart deployment.apps/argocd-server
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

## RBAC Authorization

ArgoCD RBAC configuration can be found inside `argocd-rbac-cm` configmap.

_Default:_

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
    annotations:
        meta.helm.sh/release-name: argocd
        meta.helm.sh/release-namespace: argocd
    labels:
        app.kubernetes.io/component: server
        app.kubernetes.io/instance: argocd
        app.kubernetes.io/managed-by: Helm
        app.kubernetes.io/name: argocd-rbac-cm
        app.kubernetes.io/part-of: argocd
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
| get      | View                     |
| create   | Create                   |
| update   | Modify                   |
| delete   | Delete                   |
| sync     | Sync app                 |
| override | Change params            |
| action   | Run resource actions     |
| invoke   | Invoke ArgoCD extensions |

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

## Sync Options for Application

### `syncPolicy` - controls when and how a sync will be performed

- `syncPolicy.automated` - keep an application synced to the target revision
- `syncPolicy.automated.prune` - whether to delete resources from the cluster that are not found in the sources anymore (default: `false`)
- `syncPolicy.automated.selfHeal` - whether to revert resources back to their desired state upon modification in the cluster (default: `false`)

### `syncPolicy.syncOptions` - allow to specify whole app **sync-options**

- `syncPolicy.syncOptions.CreateNamespace=true` - Creates namespace if it doesn't exist.
- `syncPolicy.syncOptions.ApplyOutOfSyncOnly=true` - To sync only **OutOfSync** resources. By default ArgoCD syncs all the resources. This may fill up API Server if there are large number of resources.
  - You can check **Result** of which resources are synced by clicking on **SYNC STATUS**.
- `syncPolicy.syncOptions.Replace=true` - Replace the changes instead of **Apply**ing.
  - `kubectl apply` is limited to smaller changes relatively.
  - To make this apply for selective resource(s), prefer passing annotations to each resources.
- `syncPolicy.syncOptions.FailOnSharedResource=true` - If a resource is already deployed in same namespace via other application, mark `application` as **OutOfSync** with warnings such as "_Service/nginx is a part of applications argocd/ application1 and application2_".
- `syncPolicy.syncOptions.PruneLast=true` - To prune resource/application after all other resources/applications are pruned.

### Resource Level

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

- If all resource has same priority, it is created on **`Kind`** order [more info](https://github.com/argoproj/argo-cd/blob/b137439c076f1f5da45edfb9b719504892e3ee7e/gitops-engine/pkg/sync/sync_tasks.go#L26).

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
