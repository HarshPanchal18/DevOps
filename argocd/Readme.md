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
