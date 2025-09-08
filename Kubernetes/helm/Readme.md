# Helm

Helm — the package manager that has revolutionized how we deploy and manage applications on Kubernetes.

The Pain Points Helm Addresses

1. YAML Proliferation: Without Helm, you’re managing hundreds of static YAML files
2. Configuration Management: Handling different configurations across dev, staging, and production
3. Version Control: Tracking changes and enabling rollbacks
4. Reusability: Sharing and reusing deployment patterns across teams
5. Complexity: Simplifying complex multi-service deployments

![Helm Architecture](https://miro.medium.com/v2/resize:fit:720/format:webp/1*U_iI4etpj2WCJxaJ61FXIA.png)

## Key Components

1. Helm Client
    The Helm client is your command-line interface to the Helm ecosystem. It handles:

    - Chart development and management
    - Repository interactions
    - Release lifecycle management
    - Template rendering and validation

2. Charts
    Charts are Helm’s packaging format — think of them as blueprints for your applications. A chart contains:

    - Kubernetes resource templates
    - Default configuration values
    - Dependencies and requirements
    - Documentation and metadata

    - Example of the Helm chart of prometheus stack:

    ```markdown
    ├── Chart.lock
    ├── charts
    │   ├── crds/
    │   ├── grafana/
    │   ├── kube-state-metrics/
    │   ├── prometheus-node-exporter/
    │   └── prometheus-windows-exporter/
    ├── Chart.yaml
    ├── README.md
    ├── templates
    │   ├── alertmanager/
    │   ├── exporters/
    │   ├── extra-objects.yaml
    │   ├── grafana/
    │   ├── _helpers.tpl
    │   ├── NOTES.txt
    │   ├── prometheus/
    │   ├── prometheus-operator/
    │   └── thanos-ruler/
    └── values.yaml

    ```

3. Repositories
    Chart repositories are HTTP servers that host packaged charts. They provide:

    - Version management
    - Distribution mechanism
    - Discovery and search capabilities
    - Access control and authentication

4. Releases
    A release represents a specific deployment of a chart with particular configuration values. Releases enable:

    - Version tracking
    - Rollback capabilities
    - State management
    - Lifecycle hooks

## The Helm Workflow

The typical Helm workflow follows these stages:

1. Chart Creation: Develop templates and values
2. Validation: Lint and test charts
3. Packaging: Bundle charts for distribution
4. Installation: Deploy to Kubernetes cluster
5. Management: Upgrade, rollback, or uninstall

## Installation

### macOS

```bash
# Using Homebrew (recommended)
brew install helm

# Using installer script
curl -fsSL -o get_helm.sh <https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3>
chmod 700 get_helm.sh
./get_helm.sh
```

### Linux

```bash
# Using snap
sudo snap install helm --classic

# Using installer script
curl <https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3> | bash

# Using package managers
# Debian/Ubuntu
curl <https://baltocdn.com/helm/signing.asc> | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get update
sudo apt-get install helm
```

### Windows

```bash
# Using Chocolatey
choco install kubernetes-helm

# Using Scoop
scoop install helm

# Using winget
winget install Helm.Helm
```

### Verification and Initial Setup

After installation, verify Helm is working correctly:

```bash
# Check Helm version
helm version

# Add the official stable repository
helm repo add stable <https://charts.helm.sh/stable>

# Update repository information
helm repo update

# List available repositories
helm repo list
```
