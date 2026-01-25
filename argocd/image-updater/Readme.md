# Auto Image Updater

## Installation

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/config/install.yaml
```

## Prerequisite

- Supports Helm and Kustomize only.

## Update strategies

- `semver` - Consider incremental semantic version (e.x. v1.5.4)
- `latest` - Most recent image found in registry (Newly pushed)
- `digest` - Update to the latest version of a given tag using the SHA digest (latest)
- `name` - Sort alphabetically, update with the highest cardinality (tag `AZ` is considered over tag `AX`)

## Update (write-back) methods - Persist image updates in source

This method can be specified at multiple levels in the **ImageUpdater** CR
    - **Global** In `spec.writeBackConfig.method` - applies to all applications unless overridden at the application level
    - **Per Application** In `spec.applicationRefs[].writeBackConfig.method` - overrides the global configuration for specific applications

### Methods

- `argocd` (default) - directly modifies the Argo CD Application resource, changing PARAMETERS of application
  - If you delete the Application resource from the cluster and re-create it, changes made by Image Updater will be gone

- `git` - create a Git commit in source repository that holds the information about the image to update to.
  - credentials configured in Argo CD will be re-used to push the commit
  - creates or updates a file at your given source named as `.argocd-source-<AppName>.yaml`
  - E.x. for kustomize repo
        ```yaml
        kustomize:
            images:
                - your-registry/nginx-argo:v1.1.5"
        ```

  - to write in a source kustomization file, instead of auto-updating file, Add `writeBackTarget: "kustomization"` under `writeBackConfig.gitConfig`

### Apply on Application

ArgoCD application should annotated with

- `argocd-image-updater.argoproj.io/image-list` contains valid "repo/image"
- `argocd-image-updater.argoproj.io/<image-name>.update-strategy` update strategy to follow
- `argocd-image-updater.argoproj.io/write-back-method` where to write image updates

#### Example

- Image updater based on Semantic version with writeBackConfig

    ```yaml
    apiVersion: argocd-image-updater.argoproj.io/v1alpha1
    kind: ImageUpdater
    metadata:
        name: semver-updater
        namespace: argocd
    spec:
        namespace: argocd # Namespace of application
        applicationRefs:
            - namePattern: ""application-nginx-*""
              images:
                - alias: ""nginx""
                  imageName: ""docker-repo/nginx-argo:v1.x""
                  commonUpdateSettings:
                    updateStrategy: ""semver""
                    allowTags: ""regexp:^v[0-9]+\\.[0-9]+\\.[0-9]+$"" # To match v*
              writeBackConfig:
                method: git
                gitConfig:
                    repository: https://github.com/org-name/application-repo.git
                    branch: ""main"" # Write changes in main branch
    ---
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
        name: application-nginx-semver-tag
        namespace: argocd
        annotations:
            argocd-image-updater.argoproj.io/image-list: docker-repo/nginx-argo:v1.x
            argocd-image-updater.argoproj.io/nginx-argo.update-strategy: semver
            argocd-image-updater.argoproj.io/write-back-method: git
    spec:
    ...
    ```

- Image updater based on SHA Digest

    ```yaml
    apiVersion: argocd-image-updater.argoproj.io/v1alpha1
    kind: ImageUpdater
    metadata:
        name: digest-updater
        namespace: argocd
    spec:
        namespace: argocd
        applicationRefs:
            - namePattern: "application-*-latest-tag"
              images:
                - alias: "argocd-nginx-digest"
                  imageName: "docker-repo/nginx-argo:latest"
                  commonUpdateSettings:
                    updateStrategy: "digest"
    ---

    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
        name: application-nginx-latest-tag
        namespace: argocd
        annotations:
            argocd-image-updater.argoproj.io/image-list: docker-repo/nginx-argo:latest
            argocd-image-updater.argoproj.io/nginx-argo.update-strategy: latest
            argocd-image-updater.argoproj.io/write-back-method: git
    spec:
    ...
    ```

### To specify the user and email for commits

- set `git.user` and `git.email` in the `configmap/argocd-image-updater-config`

    ```yaml
    data:
        git.user: "AutoImageUpdater ArgoCD"
    ```

### To change Git commit message

- set git.commit-message-template in the argocd-image-updater-config ConfigMap

    ```yaml
    data:
      git.commit-message-template: |
        build: automatic update of {{ .AppName }}

        {{ range .AppChanges -}}
        updates image {{ .Image }} tag '{{ .OldTag }}' to '{{ .NewTag }}'
        {{ end -}}
    ```

#### Supported Template Variables

- `.AppName` - name of the application that is being updated
- `.AppChanges` - a list of changes that were performed by the update.

  Each entry in this list is a struct providing the following information for each change:
  - `.Image` - the full name of the image that was updated
  - `.OldTag` - tag name or SHA digest previous to the update
  - `.NewTag` - the tag name or SHA digest that was updated to

### Authentication for Private Container Registry

- Create a pullsecret of type docker-registry

    ```bash
    kubectl create -n argocd secret docker-registry dockerhub-secret \
        --docker-username someuser \
        --docker-password s0m3p4ssw0rd \
        --docker-server "https://registry-1.docker.io"
    ```

- supply above secret into `configmap/argocd-image-updater-config`:

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
        name: argocd-image-updater-config
    data:
        registries.conf: |
            registries:
                - name: Docker Hub
                  prefix: docker.io
                  api_url: https://registry-1.docker.io
                  credentials: pullsecret:argocd/dockerhub-secret
                  defaultns: library
                  default: true
    ```

  - For generic secret, use `secret:<namespace>/<secret>`
  - For environment variable (e.x. DOCKER_HUB_CREDS=someuser:s0m3p4ssw0rd) `env:DOCKER_HUB_CREDS`
