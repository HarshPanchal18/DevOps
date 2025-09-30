# GitHub Actions

## Reusable workflows

Avoid dupliaction when creating a workflow by reusing existing workflows.

### Creating a reusable workflow

Reusable workflows are YAML-formatted files, very similar to any other workflow file. As with other workflow files, you locate reusable workflows in the `.github/workflows` directory of a repository. Subdirectories of the `workflows` directory are not supported.

For a workflow to be reusable, the values for `on` must include `workflow_call`:

```yaml
on:
  workflow_call:
```

### Using inputs and secrets in a reusable workflow

You can define inputs and secrets, which can be passed from the caller workflow and then used within the called workflow. There are three stages to using an input or a secret in a reusable workflow.

1. In the reusable workflow, use the `inputs` and `secrets` keywords to define inputs or secrets that will be passed from a caller workflow.

    ```yaml
    on:
        workflow_call:
            inputs:
                config-path:
                    required: true
                    type: string
            secrets:
                personal_access_token:
                    required: true
    ```

2. In the reusable workflow, reference the `input` or `secret` that you defined in the `on` key in the previous step.

    > [!NOTE]
    > If the secrets are inherited by using `secrets: inherit` in the calling workflow, you can reference them even if they are not explicitly defined in the `on` key. For more information, see [Workflow syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idsecretsinherit) for GitHub Actions.

    ```yaml
    jobs:
        reusable_workflow_job:
            runs-on: ubuntu-latest
            steps:
            - uses: actions/labeler@v6
              with:
                repo-token: ${{ secrets.personal_access_token }}
                configuration-path: ${{ inputs.config-path }}
    ```

    In the example above, `personal_access_token` is a secret that's defined at the repository or organization level.

3. Pass the input or secret from the caller workflow.

    To pass named inputs to a called workflow, use the with keyword in a job. Use the secrets keyword to pass named secrets. For inputs, the data type of the input value must match the type specified in the called workflow (either boolean, number, or string).

    ```yaml
    jobs:
      call-workflow-passing-data:
        uses: octo-org/example-repo/.github/workflows/reusable-workflow.yml@main
        with:
          config-path: .github/labeler.yml
        secrets:
            personal_access_token: ${{ secrets.token }}
    ```

    Workflows that call reusable workflows in the same organization or enterprise can use the `inherit` keyword to implicitly pass the secrets.

    ```yaml
    jobs:
      call-workflow-passing-data:
        uses: octo-org/example-repo/.github/workflows/reusable-workflow.yml@main
        with:
          config-path: .github/labeler.yml
        secrets: inherit
    ```

### Example reusable workflow

This reusable workflow file named `workflow-B.yml` (refer to this in the [example caller workflow](#example-caller-workflow)) takes an input string and a secret from the caller workflow and uses them in an action.

```yaml
name: Reusable workflow example

on:
  workflow_call:
    inputs:
      config-path:
        required: true
        type: string
    secrets:
      token:
        required: true

jobs:
  triage:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/labeler@v6
      with:
        repo-token: ${{ secrets.token }}
        configuration-path: ${{ inputs.config-path }}
```

### Calling a reusable workflow

You call a reusable workflow by using the `uses` keyword. Unlike when you are using actions within a workflow, you call reusable workflows directly within a job, and not from within job steps.

[`jobs.<job_id>.uses`](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_iduses)

You reference reusable workflow files using one of the following syntaxes:

- `{owner}/{repo}/.github/workflows/{filename}@{ref}` for reusable workflows in public and private repositories.
- `./.github/workflows/{filename}` for reusable workflows in the same repository.

In the first option, `{ref}` can be a SHA, a release tag, or a branch name. If a release tag and a branch have the same name, the release tag takes precedence over the branch name. Using the commit SHA is the safest option for stability and security. For more information, see Secure use reference.

If you use the second syntax option (without `{owner}/{repo}` and `@{ref}`) the called workflow is from the same commit as the caller workflow. Ref prefixes such as `refs/heads` and `refs/tags` are not allowed. You cannot use contexts or expressions in this keyword.

You can call multiple workflows, referencing each in a separate job.

```yaml
jobs:
  call-workflow-1-in-local-repo:
    uses: octo-org/this-repo/.github/workflows/workflow-1.yml@172239021f7ba04fe7327647b213799853a9eb89
  call-workflow-2-in-local-repo:
    uses: ./.github/workflows/workflow-2.yml
  call-workflow-in-another-repo:
    uses: octo-org/another-repo/.github/workflows/workflow.yml@v1
```

### Example caller workflow

This workflow file calls two workflow files. The second of these, workflow-B.yml (shown in the example reusable workflow), is passed an input (config-path) and a secret (token).

```yaml
name: Call a reusable workflow

on:
  pull_request:
    branches:
      - main

jobs:
  call-workflow:
    uses: octo-org/example-repo/.github/workflows/workflow-A.yml@v1

  call-workflow-passing-data:
    permissions:
      contents: read
      pull-requests: write
    uses: octo-org/example-repo/.github/workflows/workflow-B.yml@main
    with:
      config-path: .github/labeler.yml
    secrets:
      token: ${{ secrets.GITHUB_TOKEN }}
```
