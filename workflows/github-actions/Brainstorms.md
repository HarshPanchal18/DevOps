# Brainstorms

## What kind of ci workflow I can build on PR?

You can build a comprehensive CI workflow on every Pull Request (PR) to automate quality checks and speed up development. Typical CI workflows on PRs include:

- **Linting**: Check code style and formatting.
- **Formatting**: Auto-format code or verify formatting.
- **Type Checking**: Ensure type safety (for typed languages).
- **Unit Testing**: Run tests to verify code correctness.
- **Build**: Compile or bundle your application.
- **End-to-End (E2E) Tests**: Run integration or browser tests.

A best practice is to combine these checks into a single workflow file, organizing them as separate jobs. You can run fast checks (like lint, type check, and unit tests) in parallel, and make expensive jobs (like build or E2E tests) depend on those, so they only run if the earlier jobs succeed. This approach helps fail fast, saves resources, and provides clear feedback directly in the PR[1][5][2].

You can further customize your workflow with additional jobs, such as security scans or deployment to staging, depending on your project's needs[5][2]. Most CI platforms (like GitHub Actions, GitLab CI, Azure DevOps, or dbt Cloud) support triggering these workflows automatically on PR events and reporting the results back to the PR for review[3][6][4].

- Citations:

  1. https://blog.maximeheckel.com/posts/building-perfect-github-action-frontend-teams/
  2. https://docs.github.com/en/actions/about-github-actions/about-continuous-integration-with-github-actions
  3. https://docs.github.com/articles/getting-started-with-github-actions
  4. https://learn.microsoft.com/en-us/azure/devops/repos/git/pull-request-status?view=azure-devops
  5. https://github.blog/enterprise-software/ci-cd/build-ci-cd-pipeline-github-actions-four-steps/
  6. https://docs.getdbt.com/docs/deploy/continuous-integration
  7. https://www.youtube.com/watch?v=xdrH_m0883g
  8. https://docs.gitlab.com/ci/yaml/workflow/

---

## How can I build with PR's code?

To build with the code from a Pull Request (PR), set up a CI workflow that triggers on PR events. In GitHub Actions, you can do this by specifying the `pull_request` event in your workflow YAML file. The key steps are:

- Use the `actions/checkout` action to fetch the PR's code.
- Install dependencies and run your build/test commands.

Example workflow snippet:

```yaml
name: CI

on:
  pull_request:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install dependencies
        run: npm install
      - name: Build
        run: npm run build
```

This ensures your workflow builds and tests the actual code proposed in the PR, providing feedback directly in the PR interface[1][3][7].

- Citations:

  1. https://github.com/readme/guides/sothebys-github-actions
  2. https://docs.github.com/en/actions/about-github-actions/about-continuous-integration-with-github-actions
  3. https://graphite.dev/guides/github-pull-request-workflow
  4. https://learn.microsoft.com/en-us/azure/devops/repos/git/pull-request-status?view=azure-devops
  5. https://learn.microsoft.com/en-us/azure/devops/repos/git/pull-requests?view=azure-devops
  6. https://graphite.dev/guides/how-to-write-custom-github-actions-for-code-reviews
  7. https://blog.devops.dev/automate-your-workflow-a-guide-to-ci-cd-with-github-actions-3f395d60ba69
  8. https://stackoverflow.com/questions/68057744/create-pull-request-with-github-action
  9. https://github.com/marketplace/actions/pr-build-merge
  10. https://www.paigeniedringhaus.com/blog/automatically-create-a-pull-request-against-a-feature-branch-with-git-hub-actions

---

## What are some examples of custom GitHub Actions for code reviews?

Here are some examples of custom GitHub Actions you can build or use to automate code reviews:

- **Automated Commenting**: Create an action that leaves feedback or comments on pull requests based on custom logic, such as checking for specific file changes or patterns in code[1][6].
- **Custom Linting/Style Checks**: Build an action that runs your own linters or code style checks, and posts the results as PR comments or status checks[1][3].
- **Automatic Approval**: Write an action that automatically approves pull requests if they meet certain criteria, like passing all tests or including required reviewers[6].
- **File Change Enforcement**: Develop an action to ensure that certain files (e.g., documentation or changelogs) are updated when code changes, and block merging if not[1].
- **Labeling and Assignment**: Custom actions can automatically label PRs or assign reviewers based on code ownership or file paths[3][7].

These actions are typically triggered on `pull_request` events and can be tailored to your team's workflow, providing immediate feedback and enforcing standards automatically[1][6].

- Citations:

  1. https://graphite.dev/guides/how-to-write-custom-github-actions-for-code-reviews
  2. https://docs.github.com/en/actions/sharing-automations/creating-actions/about-custom-actions
  3. https://www.software.com/src/github-actions-for-faster-code-reviews
  4. https://resources.github.com/learn/pathways/automation/advanced/building-your-first-custom-github-action/
  5. https://docs.aws.amazon.com/codeguru/latest/reviewer-ug/working-with-cicd.html
  6. https://victoronsoftware.com/posts/typescript-github-action/
  7. https://blog.pixelfreestudio.com/how-to-use-github-for-code-reviews-and-collaboration/
  8. https://codefresh.io/learn/github-actions/github-actions-tutorial-and-examples/

---

## How can I manually trigger builds for specific pull requests(PR)?

To manually trigger builds for specific pull requests, you have a few options depending on your CI system:

- **GitHub Actions:**
  You can set up a workflow with the `workflow_dispatch` event, allowing you to trigger the workflow manually from the GitHub UI. When running the workflow, select the PR’s source branch to build its code.

- **Bitbucket Pipelines:**
  Use the Bitbucket API to manually trigger a pipeline for a specific PR, even if normal triggers are skipped. Alternatively, push an empty commit to the PR’s source branch to start the pipeline[2].

- **Jenkins:**
  Use the “Build Now” button to manually trigger a build for the PR’s source branch[7].

- **Google Cloud Build:**
  Create a manual trigger and select the PR’s source branch when starting the build[5].

These methods let you build PRs on demand without waiting for automatic triggers.

- Citations:

  1. https://stackoverflow.com/questions/61350543/how-do-i-trigger-build-and-test-on-a-pull-request-in-azure-devops
  2. https://confluence.atlassian.com/bbkb/how-do-i-manually-trigger-a-pull-requests-pipeline-on-a-pr-1387601529.html
  3. https://docs.github.com/actions/learn-github-actions/events-that-trigger-workflows
  4. https://devcenter.bitrise.io/en/builds/starting-builds/triggering-builds-automatically.html
  5. https://cloud.google.com/build/docs/triggers
  6. https://learn.microsoft.com/en-us/azure/devops/pipelines/release/deploy-pull-request-builds?view=azure-devops
  7. https://geoweb.princeton.edu/research/jenkins-doc/tutorial_project.html
  8. https://community.jenkins.io/t/how-to-trigger-build-in-each-change-for-specific-branches-only/3256

---

## What are some advanced GitHub Actions for enforcing coding standards?

### Advanced GitHub Actions for Enforcing Coding Standards

**1. Super Linter**
A popular all-in-one action that runs multiple linters (e.g., ESLint, Pylint, RuboCop) across your codebase, supporting many languages and enforcing consistent standards automatically on every push or pull request[4][6].

**2. Custom Linter and Formatter Actions**
You can integrate advanced linters and formatters-like ESLint (JavaScript), Black (Python), Prettier (multi-language), or PHP Coding Standards Fixer-into your workflows. These tools catch style issues, bugs, and enforce formatting before code is merged[2][4][6].

**3. Code Scanning and Static Analysis**
Use advanced code scanning tools such as CodeQL or SonarCloud via GitHub Actions to perform deep static analysis, catching security vulnerabilities and complex code quality issues[3][6].

**4. Branch Protection with Required Status Checks**
Combine your linting, formatting, and analysis actions with branch protection rules to ensure all checks must pass before merging, strictly enforcing standards at the repository level[4].

**5. Enforce Policies at Enterprise Level**
For organizations, GitHub provides policy enforcement to restrict which actions can be used, mandate code scanning, and require specific workflow steps, giving admins control over coding standards across all repos[1][8].

**6. Reviewdog Integration**
Actions like Reviewdog can run linters and post results as inline PR comments, giving immediate, actionable feedback to contributors[2].

**7. Custom Workflows with Dependencies**
Leverage advanced workflow features such as job dependencies (`needs` keyword) to ensure code quality checks run in sequence and only allow further jobs (like deployment) if standards are met[7].

---

These advanced setups help automate and strictly enforce coding standards, improving code quality and team productivity.

- Citations:

  1. https://docs.github.com/en/enterprise-cloud@latest/admin/enforcing-policies/enforcing-policies-for-your-enterprise/forcing-policies-for-github-actions-in-your-enterprise
  2. https://github.com/sdras/awesome-actions
  3. https://docs.github.com/en/code-security/code-scanning/creating-an-advanced-setup-for-code-scanning/customizing-your-advanced-setup-for-code-scanning
  4. https://graphite.dev/guides/enhancing-code-quality-github
  5. https://systemshogun.com/p/enforce-coding-standards-with-github
  6. https://dev.to/alexmercedcoder/a-deep-dive-into-github-actions-from-software-development-to-data-engineering-bki
  7. https://github.blog/developer-skills/github/7-advanced-workflow-automation-features-with-github-actions/
  8. https://docs.github.com/github-ae@latest/admin/policies/enforcing-policies-for-your-enterprise/enforcing-policies-for-code-security-and-analysis-for-your-enterprise

---

## What are some advanced GitHub Actions features for automating security checks?

### Advanced GitHub Actions Features for Automating Security Checks

- **Code Scanning with CodeQL**
  Automate static analysis using CodeQL to detect security vulnerabilities in code on every push or pull request. Code scanning can be configured to run on specific branches or events, providing early detection and actionable alerts[5][6].

- **Secret Scanning and Push Protection**
  Enable secret scanning to automatically detect credentials, API keys, and other sensitive information in your codebase. Push protection can block the commit if a secret is detected, preventing leaks before code is merged[1][5].

- **Dependency Review and Dependabot**
  Use dependency review actions to automatically check for known vulnerabilities in third-party libraries and dependencies. Dependabot can be integrated to alert and automatically open pull requests for vulnerable dependency updates[5][8].

- **Security Hardening for Workflows**
  Store sensitive data as encrypted secrets, use CODEOWNERS to monitor workflow changes, and restrict which actions can be used in your workflows. These practices help prevent misuse and reduce the risk of supply chain attacks[3][4].

- **Workflow Visualization and Job Dependencies**
  Use workflow visualization tools and the `needs` keyword to create dependencies between jobs, ensuring that security checks must pass before other jobs (like deployment) run[2].

- **Integration with DAST and Third-Party Tools**
  Integrate Dynamic Application Security Testing (DAST) tools and other third-party security scanners directly into your workflows for comprehensive coverage of both static and dynamic vulnerabilities[5].

These features enable you to automate security checks, enforce best practices, and respond quickly to vulnerabilities directly within your CI/CD pipeline.

- Citations:

  1. https://docs.github.com/en/get-started/learning-about-github/about-github-advanced-security
  2. https://github.blog/developer-skills/github/7-advanced-workflow-automation-features-with-github-actions/
  3. https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions
  4. https://blog.gitguardian.com/github-actions-security-cheat-sheet/
  5. https://www.stackhawk.com/blog/maximize-security-with-github-advanced-security-and-dast/
  6. https://ambuzrnjn33.hashnode.dev/mastering-github-actions-the-ultimate-guide-to-automating-your-development-workflow
  7. https://docs.github.com/articles/getting-started-with-github-actions
  8. https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-githubs-security-features-to-secure-your-use-of-github-actions

---

## How can I use secret scanning to detect and alert on sensitive data in my repository?

You can use GitHub’s secret scanning to automatically detect and alert on sensitive data-such as API keys, passwords, and tokens-in your repository. Once enabled, secret scanning analyzes your entire repository (including commit history, pull requests, issues, and wikis) for known secret patterns and generates real-time alerts when a secret is found[1][5].

**How to enable and use secret scanning:**

- Go to your repository’s **Settings** > **Code Security and analysis**.
- Enable **GitHub Advanced Security** and then enable **Secret Scanning** for your repository[5].
- Optionally, enable **Push Protection** to block commits containing secrets before they’re pushed[2][5].
- When a secret is detected, GitHub creates an alert in the **Security** tab, notifying repository administrators and contributors with details about the secret’s location and remediation steps[1][4].
- You can review and resolve alerts directly from the Security tab, and use the REST API to monitor alerts across repositories[1].

Secret scanning can also be customized with custom patterns and validity checks, and it integrates with service providers to help revoke exposed credentials automatically[1].

- Citations:

  1. https://docs.github.com/code-security/secret-scanning/about-secret-scanning
  2. https://docs.github.com/en/code-security/secret-scanning/enabling-secret-scanning-features
  3. https://www.akeyless.io/blog/what-is-secrets-scanning/
  4. https://learn.microsoft.com/en-us/azure/devops/repos/security/github-advanced-security-secret-scanning?view=azure-devops
  5. https://www.sentinelone.com/cybersecurity-101/cloud-security/github-secret-scanning/
  6. https://www.jit.io/resources/appsec-tools/git-secrets-scanners-key-features-and-top-tools-
  7. https://www.wiz.io/academy/secret-scanning
  8. https://www.checkpoint.com/cyber-hub/cloud-security/what-is-code-security/top-5-secret-scanning-tools/

---
