# Trivy Commands

## Installation in Linux

```bash
apt install trivy
```

## Scan a container image

```bash
trivy image alpine/git
```

### Options

> `--scanners strings` - comma-separated list of what security issues to detect (vuln,misconfig,secret,license) (default [vuln,secret])

> `--skip-dirs strings` - specify the directories or glob patterns to skip

> `--skip-files strings` - specify the files or glob patterns to skip

> `--ignore-status strings` - comma-separated list of vulnerability status to ignore **(unknown,not_affected,affected,fixed,under_investigation,will_not_fix,fix_deferred,end_of_life)**

> `--ignore-unfixed` - display only fixed vulnerabilities

```bash
trivy image -f json -o jenkins-result.json --severity HIGH,CRITICAL jenkins
```

## Scan a FileSystem

```bash
trivy fs /path/to/file
```

## Scan a repo

```bash
trivy repo /path/to/repo|repo_url
```

## Scan a Kubernetes cluster

```bash
trivy k8s --report=summary cluster # Run inside a Kubernetes cluster.
```

### Options

> `--burst int` - specify the maximum burst for throttle (default 10)

> `--disable-node-collector` - When the flag is
activated, the node-collector job will not be executed, thus skipping misconfiguration findings on the node.

> `--exclude-kinds strings` - indicate the kinds exclude from scanning (example: node)

> `--exclude-namespaces strings` - indicate the namespaces excluded from scanning (example: kube-system)

> `--exclude-nodes strings` - indicate the node labels that the node-collector job should exclude from scanning (example: kubernetes.io/arch:arm64,team:dev)

> `--exclude-owned` - exclude resources that have an owner reference

> `--include-kinds strings` - indicate the kinds included in scanning (example: node)

> `--include-namespaces strings` - indicate the namespaces included in scanning (example: kube-system)
