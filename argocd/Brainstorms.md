# ArgoCD Brainstorms

## Does controller continuously monitor the given repo source for sync status? Or it is invoke after git push?

Short answer:
The Argo CD controller continuously reconciles the desired state in the Git repo, but it does so on a polling interval (default ≈ 3 minutes). It can also be prompted instantly by a Git‑webhook if you configure one.

### How it works

| Event | What Argo CD does |
|---|---|
| Periodic poll (default every 3 min. See `configs.cm.timeout.reconciliation`) | The controller reads the repo, compares the manifest SHA with what’s applied in the cluster, and updates the Sync Status and Health fields. If drift is detected it marks the app "**Out‑of‑Sync**". |
| Git webhook (optional) | A push to the repo triggers an HTTP POST to Argo CD’s webhook endpoint. The controller receives the event and immediately re‑evaluates the affected applications, updating sync status right away. |
| Manual actions (e.g., argocd app sync, UI click) | Forces an immediate reconciliation regardless of the poll/webhook schedule. |

### Practical points

- No need to run a command after each push – the controller will notice the change on its next poll (or instantly via webhook).
- If you want near‑real‑time detection, enable a Git webhook in the repository settings and point it to https://<argocd‑server>/api/webhook.
- The poll interval can be changed with the --repo-server-reconciliation-interval flag on the argocd-repo-server deployment.
- Even when the repo isn’t changing, the controller still continuously checks the live cluster to keep health/status up‑to‑date.

> So, yes, the controller monitors the repo continuously on a regular interval, and you can make it react immediately after a git push by adding a webhook.

## What is selfHeal?

selfHeal – a built‑in Argo CD feature that automatically restores a resource to the state defined in Git when it drifts (is changed manually or by another controller).

| Aspect | Details |
|---|---|
| What it does | Detects drift during the normal sync status check and runs a background sync to “heal” the resource back to the desired manifest. |
| When it runs | On every periodic health check (default every 3 min) and after any manual sync that succeeds. |
| How to enable | Set resource.customizations.<group>/<kind>.selfHeal: true in the argocd-cm ConfigMap, or globally with application.selfHeal: true in the Application spec. |
| Typical use‑cases | - Prevent accidental manual edits from persisting.<br>- Keep third‑party controllers (e.g., Helm, Kustomize) from overwriting Argo CD’s desired state.<br>- Ensure compliance in environments where users may “kubectl edit”. |
| Things to watch | - Does not fix resources that fail health checks; they must become Healthy first.<br>- May cause a sync loop if another controller continuously rewrites the object. Use with care in hybrid‑operator setups. |

### CLI example

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
    name: my-app
spec:
    selfHeal: true # enable per‑application
```

Bottom line: selfHeal makes Argo CD auto‑correct drift, keeping the live cluster continuously aligned with the Git‑defined desired state. Use it when you want "set‑and‑forget" compliance, but be aware of potential conflicts with other controllers.

## Does it run self heal if I scale up the deployment? If yes, how to handle such case so that I do not need to make a new commit for scaling?

Yes — **Argo CD *will* self-heal if you scale a Deployment manually**, *but only if self-heal is enabled*.

### Why this happens

If your Application has:

```yaml
syncPolicy:
  automated:
    selfHeal: true
```

and you run:

```bash
kubectl scale deployment my-app --replicas=5
```

then:

- Argo CD detects **drift**
- Git says `replicas: 3`
- Cluster says `replicas: 5`
- Argo CD **reverts it back to 3**

This is expected GitOps behavior.

---

## How to scale **without** making a new Git commit

### **Best practice: Remove `replicas` from Git**

Let Kubernetes control scaling.

#### Do this

```yaml
spec:
  # replicas: 3   <- remove this
  template:
    ...
```

Then:

- Manual `kubectl scale` **will NOT be reverted**
- Argo CD ignores replica count
- This is the **recommended approach**

---

### **Use HPA (Recommended for prod)**

Define scaling declaratively *once*:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
```

- Argo CD manages the HPA object
- HPA manages `replicas`
- No Git commit needed for scaling events
- Argo CD does **not** fight HPA

#### This is the **cleanest GitOps-compliant solution**

---

### Option: Ignore replica drift (advanced)

You can tell Argo CD to ignore replica differences:

```yaml
spec:
  ignoreDifferences:
  - group: apps
    kind: Deployment
    jsonPointers:
    - /spec/replicas
```

Effect:

- Argo CD won’t self-heal replica changes
- Manual scaling survives

> Use carefully — this weakens Git as source of truth.

---

### What **not** to do

- Disable self-heal entirely
- Manually scale StatefulSets without planning
- Rely on kubectl scale in production regularly

---

### Quick decision table

| Requirement              | Best choice            |
| ------------------------ | ---------------------- |
| Temporary manual scaling | Remove `replicas`      |
| Production auto-scaling  | HPA                    |
| Mixed control            | ignoreDifferences      |
| Strict GitOps            | Commit replica changes |

---

## How conflicts are resolved

A conflict happens when **multiple actors try to change the same field** of a Kubernetes resource:

- Git (via Argo CD)
- A human (`kubectl edit`, `scale`)
- Another controller (HPA, operator)

Example:

```yaml
spec:
  replicas: 3   # in Git
```

but someone runs:

```bash
kubectl scale deployment app --replicas=5
```

---

### How Argo CD applies changes

ArgoCD uses **server-side apply** (SSA) by default.

That means:

- Every field has an **owner** (field manager)
- Kubernetes tracks ownership per field in `managedFields`

ArgoCD’s field manager ≈ `argocd-controller`

---

### Conflict resolution rules (the core logic)

#### 1. If Argo CD owns the field → **Argo CD wins**

- Field defined in Git
- Manual change modifies the same field
- Argo CD detects drift
- On next sync, Argo CD **re-applies Git value**

Example: `spec.replicas`, `image`, `env`

---

#### 2. If another controller owns the field → **That controller wins**

Typical examples:

- HPA → `spec.replicas`
- Operator → CR fields

ArgoCD:

- **Does NOT fight**
- Respects Kubernetes ownership
- No `sync` loop

This is why **HPA works cleanly with ArgoCD**.

---

#### 3. If ArgoCD does NOT manage the field → **No conflict**

If a field is **not in Git**, ArgoCD ignores it.

Example:

```yaml
spec:
  template:
    spec:
      containers:
      - name: app
        image: myapp:v1
        # replicas missing
```

Manual scaling:

```bash
kubectl scale ...
```

- ArgoCD won’t revert it
- No conflict

---

#### 4. Hard conflicts (rare but real)

Occurs when:

- Two managers try to own the same field
- Neither releases ownership

Kubernetes returns:

```text
conflict: field is managed by another manager
```

ArgoCD behavior:

- Sync **fails**
- App shows **Degraded**
- Requires human intervention

---

### How ArgoCD lets you control conflicts

#### Ignore specific fields

```yaml
spec:
  ignoreDifferences:
  - group: apps
    kind: Deployment
    jsonPointers:
    - /spec/replicas
```

ArgoCD:

- Skips diff
- Skips self-heal
- Lets humans or controllers manage it

---

#### Force ownership (dangerous)

```bash
argocd app sync --force
```

- ArgoCD deletes & recreates resource
- Overrides conflicts (Can cause downtime)

---

### Visual flow

```text
Change happens →
Who owns the field?
 ├─ ArgoCD → Git value applied
 ├─ HPA/Controller → Controller value kept
 └─ Ignored field → No action
```

---

### Practical best practices

- Remove mutable fields from Git
- Keep Git for **intent**, not runtime state
- Avoid `--force` unless recovering

---

### One-line takeaway

**Conflicts are resolved by Kubernetes `field ownership`; ArgoCD only enforces the fields it owns.**
