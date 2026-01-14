# GitOps - A Simple, Consistent, and Secure approach to manage your environments

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

> Handle with care: Anyone with this token has full cluster-admin access to your target cluster.

> Use the CLI if possible: When you run `argocd cluster add <name>`, the CLI does all of the steps above automatically for you, including generating the token and creating the secret in Argo CD. It is much safer and easier.

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
htpasswd -bnBC 10 "" admin123 | tr -d ':\n'

# e.x. $2y$10$E0rosdjd./3d1xajkCm0qeyKCxYlBsX5c41nQrCtn3ke78pfCyGc6

# Encode token
echo -n "$2y$10$E0rosdjd./3d1xajkCm0qeyKCxYlBsX5c41nQrCtn3ke78pfCyGc6" | base64

# e.x. eTAuLzNkMXhhamtDbTBxZXlLQ3hZbEJzWDVjNDFuUXJDdG4za2U3OHBmQ3lHYzY=

# Patch secret to update value
kubectl -n argocd patch secret argocd-secret -p '{"data": {"admin.password": "eTAuLzNkMXhhamtDbTBxZXlLQ3hZbEJzWDVjNDFuUXJDdG4za2U3OHBmQ3lHYzY="}}'
kubectl -n argocd patch secret argocd-secret -p '{"data": {"admin.passwordMtime": "'$(date +%FT%T%Z | base64)'"}}'

# Restart argocd server pod
kubectl -n argocd delete pods -l app.kubernetes.io/name=argocd-server
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

| Action   | Meaning              |
| -------- | -------------------- |
| get      | View                 |
| list     | List                 |
| create   | Create               |
| update   | Modify               |
| delete   | Delete               |
| sync     | Sync app             |
| override | Change params        |
| action   | Run resource actions |

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

    policy.default: "role:readonly" # Anyone not explicitly mapped gets read-only access
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
