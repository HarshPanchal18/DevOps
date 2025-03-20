# Theory and methods

## Introduction

* Spinnaker is an open-source, multi-cloud continuous delivery platform that helps you release software changes with high velocity and confidence.

* Open sourced by Netflix and heavily contributed to by Google, it supports all major cloud vendors (AWS, Azure, App * Engine, Openstack, etc.) including Kubernetes.

## What Spinnaker Provides?

* Application management and Application Deployment are its two core features.

### Application Management

Spinnaker's application management features can be used to view and manage your cloud resources.

Modern tech organizations operate collections of services — sometimes referred to as “applications” or “microservices”. A Spinnaker application models this concept.

Applications, Clusters, and Server Groups are the key concepts Spinnaker uses to describe services. Load balancers and Firewalls describe how services are exposed to users.

![Application-Management](application-management.png)

#### Application

* An application in Spinnaker is a collection of clusters, which in turn are collections of server groups. The application also includes firewalls and load balancers.

* An application represents the service which needs to be deployed using Spinnaker, all configuration for that service, and all the infrastructure on which it will run.

* Normally, a different application is configured for each service, though Spinnaker does not enforce that.

#### Cluster

Clusters are logical groupings of Server Groups in Spinnaker.

Note: Cluster, here, does not map to a Kubernetes cluster. It’s merely a collection of Server Groups, irrespective of any Kubernetes clusters that might be included in your underlying architecture.

#### Server Group

The base resource, the Server Group, identifies the deployable artifact (VM image, Docker image, source location) and basic configuration settings such as number of instances, autoscaling policies, metadata, etc. This resource is optionally associated with a Load Balancer and a Firewall.

When deployed, a Server Group is a collection of instances of the running software (VM instances, Kubernetes pods).

#### Load Balancer

A Load Balancer is associated with an ingress protocol and port range. It balances traffic among instances in its Server Groups.

Optionally, health checks can be enabled for a load balancer, with flexibility to define health criteria and specify the health check endpoint.

#### Firewall

A Firewall defines network traffic access. It is effectively a set of firewall rules defined by an IP range (CIDR) along with a communication protocol (e.g., TCP) and port range.

### Application Deployment

#### Pipeline

The pipeline is the key deployment management construct in Spinnaker. It consists of a sequence of actions, known as stages. You can pass parameters from stage to stage along the pipeline.

You can start a pipeline manually, or you can configure it to be automatically triggered by an event, such as a Jenkins job completing, a new Docker image appearing in your registry, a CRON schedule, or a stage in another pipeline.

You can configure the pipeline to emit notifications, by email, SMS or HipChat, to interested parties at various points during pipeline execution (such as on pipeline start/complete/fail).

#### Stage

A Stage in Spinnaker is an atomic building block for a pipeline, describing an action that the pipeline will perform. You can sequence stages in a Pipeline in any order, though some stage sequences may be more common than others.

Spinnaker provides a number of stages such as Deploy, Resize, Disable, Manual Judgment, and many more. The full list of stages and read about implementation details for each provider [here](https://spinnaker.io/docs/reference/providers/).

#### Deployment Strategies

Spinnaker supports all the cloud native deployment strategies including Red/Black (a.k.a Blue/Green), Rolling red/black and Canary deployments, etc.

### What is Spinnaker Made Of?

* Spinnaker is composed of a number of independent microservices:
* `Deck` is the browser-based UI.
* `Gate` is the API gateway. The Spinnaker UI and all API callers communicate with Spinnaker via Gate.
* `Orca` is the orchestration engine. It handles all ad-hoc operations and pipelines.
* `Clouddriver` is responsible for all mutating calls to the cloud providers and for indexing/caching all deployed resources.
* `Front50` is used to persist the metadata of applications, pipelines, projects and notifications.
* `Rosco` is the bakery. It is used to produce machine images (for example GCE images, AWS AMIs, Azure VM images). It currently wraps Packer, but will be expanded to support additional mechanisms for producing images.
* `Igor` is used to trigger pipelines via continuous integration jobs in systems like Jenkins and Travis CI, and it allows Jenkins/Travis stages to be used in pipelines.
* `Echo` is Spinnaker’s eventing bus. It supports sending notifications (e.g. Slack, email, Hipchat, SMS), and acts on incoming webhooks from services like GitHub.
* `Fiat` is Spinnaker’s authorization service. It is used to query a user’s access permissions for accounts, applications and service accounts.
* `Kayenta` provides automated canary analysis for Spinnaker.
* `Halyard` is Spinnaker’s configuration service. Halyard manages the lifecycle of each of the above services. It only interacts with these services during Spinnaker start-up, updates, and rollbacks.
* By default, Spinnaker binds ports accordingly for all the above-mentioned microservices. For us, the UI (Deck) will be exposed onto Port 9000.
