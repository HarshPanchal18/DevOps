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
