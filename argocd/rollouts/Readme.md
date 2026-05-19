# Argo Rollouts - Advanced Kubernetes deployment strategies such as `Canary` and `Blue-Green` made easy

The tool is implemented as a Kubernetes controller and a collection of Custom Resource Definitions (CRDs). The main CRD is Rollout — it acts as **a replacement for the Kubernetes Deployment object** and allows you to define deployments that use the advanced update strategies that Argo provides.

Without creating a **Rollout**, you can only use the rolling update and complete recreation deployment strategies that are included with Kubernetes.

When you add a **Rollout** object to your cluster, the Argo controller detects its presence and then creates, replaces, and removes Pods as required.

## What is the difference between Argo CD and Argo Rollouts?

Argo Rollouts is often used in conjunction with Argo CD, the Argo project’s continuous delivery (CD) tool. Argo CD implements **declarative GitOps-driven CD** for Kubernetes, while Rollouts offers a controller and CRDs that let you robustly **manage blue-green and canary deployments**.

You can use Argo Rollouts without ArgoCD, or vice versa, but combining them both produces a fully automated end-to-end workflow for safely deploying changes to your apps.

## Argo Rollouts deployment workflow

The core Argo Rollouts workflow is as follows:

1. Deploy your new app release.
2. Test the new release.

    For blue-green deployments, this will be done by developers, whereas canary deployments will be tested by a small percentage of real users. As you gain confidence in the canary, you can increase the proportion of traffic that’s directed to it.

3. Once you’re sure the deployment has been successful, promote it to a full rollout.

    Argo will then remove the old deployment and ensure all traffic is directed to the new one. At this point, you can begin iterating on your next change, ready to repeat the cycle.

## Deployment Strategies

### Canary Deployment

A Canary Deployment is a progressive release strategy where a new version of an application is rolled out to a small subset of users or infrastructure before being gradually promoted to the entire environment.

This approach helps minimize risks by allowing teams to monitor performance, detect issues early, and roll back changes if needed, ensuring a safer and more controlled deployment process. You can also configure the background Analysis to execute during the rollout. If the analysis is unsuccessful the rollout will be aborted.

Here’s how it works:

1. Deploy the Canary Version to a Small User Segment

    - Your production system (v1) is currently serving all users.
    - You roll out the new pricing engine (v2) to just 5% of users, randomly selected from a single region (e.g., Washington  customers).
    - A feature flag ensures that only these users see the new pricing model, while the rest continue using the old system.

2. Monitor Key Metrics

    - If the metrics show positive results with no major issues, you increase exposure to 20% of users.

3. Incrementally Increase Traffic to the New Version

    - Over the next few days, traffic to v2 is gradually increased from 20% → 50% → 100%.
    - Each step is carefully monitored to detect anomalies or unexpected behavior.
    - If a major issue is detected, the team can immediately roll back to v1 without affecting most users.

4. Full Rollout and Decommissioning the Old Version

    - Once the new pricing engine has proven its reliability and effectiveness, 100% of users are switched over to v2.
    - The old version (v1) is retired, but the system keeps historical data to compare performance over time.

### Blue-Green Deployment

This method runs two application versions in parallel - **Blue (current)** and **Green (new)**. Traffic remains on the Blue version while the Green version undergoes validation. Once the Green version is confirmed stable, traffic is instantly switched over. If issues arise, rolling back is seamless by reverting traffic to the Blue version.

This strategy ensures zero downtime but requires additional infrastructure to run both versions simultaneously.

The Blue-Green Deployment strategy works in the following manner:

1. The application starts in a steady state, with the current version (**revision 10**) running. Both the active service and preview service point to revision 1.

2. Someone from your team initiates an update by modifying the pod template (`spec.template.spec`). This creates a new ReplicaSet (**revision 2**) with zero replicas.

3. The preview service is updated to point to **revision 2**, while the active service continues to serve traffic from **revision 1**. You maybe wondering how the Preview service points to the revision.

4. The rollouts controller does this, which sets a unique hash label on the new revision replicaset, and the service uses a `selector` that selects that new hash label.

5. **Revision 2** is scaled up to the specified replica count (`spec.replicas` or `previewReplicaCount` if set). Once the new pods are fully available, Argo Rollouts performs a pre-promotion analysis to validate the new version.

    - `previewReplicaCount` is an optional field in Argo Rollouts that allows you to specify a different number of replicas for the preview version (the new version being tested) before it is fully promoted.

6. If pre-promotion checks pass, the rollout pauses if `autoPromotionEnabled` is **false**. If `autoPromotionSeconds` is set, the rollout waits for the specified duration before continuing automatically.

    - `autoPromotionEnabled` and `autoPromotionSeconds` control how and when a new version in a blue-green deployment is promoted from the preview stage to active.
    - By default, `autoPromotionEnabled` is set to true, meaning the rollout automatically promotes the new version as soon as it passes pre-promotion analysis.
    - However, if `autoPromotionEnabled` is set to false, the rollout pauses after deploying the new version, allowing a manual review before promoting it. This is useful when teams want to validate a release before switching live traffic.
    - Additionally, `autoPromotionSeconds` provides a middle ground between **automatic** and **manual** promotion by introducing a time delay before the new version is promoted. For example, if `autoPromotionSeconds` is set to 60, the rollout pauses for 60 seconds before automatically promoting the new version. This brief waiting period allows teams to catch any obvious issues before the update goes live.

7. If `previewReplicaCount` was used, **revision 2** is scaled to match `spec.replicas` before promotion.

8. The **active** service is updated to point to **revision 2**, making it the new live version. At this point, **revision 1** is no longer in use.

9. A post-promotion analysis runs to verify that the update is stable.

    - If analysis is successful, **revision 2** is marked as stable, and the rollout is considered fully promoted. After waiting for `scaleDownDelaySeconds` (default 30s), revision 1 is scaled down, completing the deployment process.

## Installation

### Install Argo Rollouts

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm install argo-rollouts argo/argo-rollouts -n argo-rollouts --create-namespace
```

### Install Argo Rollouts `kubectl` plugin

```bash
curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
chmod +x kubectl-argo-rollouts-linux-amd64
mv kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts

# Check plugin version
kubectl argo rollouts version
```

## Integrating with Argo CD UI

```yaml
server:
  initContainers:
    - name: rollout-extension
      image: quay.io/argoprojlabs/argocd-extension-installer:v0.0.8
      env:
      - name: EXTENSION_URL
        value: https://github.com/argoproj-labs/rollout-extension/releases/download/v0.3.7/extension.tar
      volumeMounts:
        - name: extensions
          mountPath: /tmp/extensions/
      securityContext:
        runAsUser: 1000
        allowPrivilegeEscalation: false
  volumeMounts:
    - name: extensions
      mountPath: /tmp/extensions/
  volumes:
    - name: extensions
      emptyDir: {}
```

## Rollout changes

```bash
kubectl argo rollouts set image demo-rollout nginx=nginx:1.27
```

Or update in GitHub Repository if following GitOps methodology
