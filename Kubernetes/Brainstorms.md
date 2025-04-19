# Troubleshootings

## Your jenkins pipeline fails post-merge. The log points to a missing env variables. How do you fix this without affecting other devs?

To fix the Jenkins pipeline failure without affecting other developers, you can follow these steps:

1. **Identify the specific environment variables**: Check the Jenkins pipeline log to identify which environment variables are missing.

2. **Update your local pipeline configuration**: In your local `Jenkinsfile`, add the missing environment variables using the `env` directive. For example:

    ```groovy
    env.MY_VAR = 'my_value'
    ```

    This will set the `MY_VAR` environment variable to `my_value` only for your local pipeline runs.

3. **Commit and push changes**: Commit the changes to your local `Jenkinsfile` and push them to the remote repository.

4. **Trigger a new pipeline run**: Trigger a new pipeline run to test if the environment variables are correctly set.

5. **Verify the fix**: Verify that the pipeline runs successfully and the environment variables are correctly set.

By following these steps, you can fix the Jenkins pipeline failure without affecting other developers, as the changes are specific to your local pipeline configuration.

---

## What are your immediate steps if a teammate accidently pushed .env to the remote?

If a teammate accidentally pushes a `.env` file to the remote repository, follow these immediate steps:

1. **Notify the team**: Inform the team about the accidental push to prevent further commits or updates from the remote repository.

2. **Fetch the latest changes**: Run `git fetch` to fetch the latest changes from the remote repository.

3. **Check out a new branch**: Create a new branch or check out an existing one to isolate the changes. This will prevent any local changes from being overwritten.

    ```bash
    git checkout -b fix-env
    ```

4. **Delete the remote .env file**: Use `git filter-branch` or `git filter-repo` to remove the `.env` file from the remote repository. You can also use `git rm --cached` to delete the file from the index, but this might not be enough to remove the file from the remote repository.

    ```bash
    git filter-branch --tree-filter 'rm .env' --prune-empty HEAD
    ```

    **or**

    ```bash
    git filter-repo --path .env --to-keep '' --force
    ```

5. **Force-push the changes**: Force-push the updated branch to the remote repository to overwrite the existing changes.

    ```bash
    git push origin fix-env --force
    ```

6. **Update the main branch**: Once the `.env` file is removed from the remote repository, update the main branch to reflect the changes.

    ```bash
    git checkout main
    git merge fix-env
    ```

7. **Delete the temporary branch**: Once the changes are merged, delete the temporary branch.

    ```bash
    git branch -d fix-env
    ```

By following these steps, you can quickly and safely remove the `.env` file from the remote repository.

---

## You're asked to deploy a new app version live with zero downtime. What strategy ensures zero impact to active users?

To deploy a new app version live with zero downtime, you can use a **Blue-Green Deployment** strategy. Here's a high-level overview of the process:

1. **Create two identical environments**: Set up two identical environments, one for the old version (blue) and one for the new version (green).
2. **Route traffic to the old environment**: Route all incoming traffic to the blue environment, which is the current live version of the app.
3. **Update the green environment**: Update the green environment to the new version of the app.
4. **Test the green environment**: Perform thorough testing on the green environment to ensure it's working as expected.
5. **Route traffic to the green environment**: Once testing is complete, route all incoming traffic to the green environment, which is now the new live version of the app.
6. **Deactivate the blue environment**: Deactivate the blue environment, and it can be used for future rollbacks or testing.

**Benefits of Blue-Green Deployment**:

* **Zero downtime**: Users are not affected during the deployment process.
* **Easy rollbacks**: If issues arise with the new version, you can quickly roll back to the previous version by routing traffic back to the blue environment.
* **Improved testing**: The green environment allows for thorough testing before deploying the new version to production.

**Additional considerations**:

* **Load balancers**: Use load balancers to route traffic between the two environments.
* **Monitoring**: Monitor both environments to ensure a smooth transition.
* **Communication**: Communicate the deployment plan to all stakeholders to ensure a smooth experience for users.

By following a Blue-Green Deployment strategy, you can ensure a seamless transition to the new app version with zero downtime and minimal risk.

---

## Your AWS bill jumped 60%. The app usage barely changed. What would you investigate first?

To investigate a 60% increase in the AWS bill with minimal change in app usage, I would start by checking the following:

1. **Cost and Usage Reports**: Review the `Cost and Usage Reports` in the AWS Management Console to identify the specific services that have contributed to the increase. This will give me a high-level overview of the costs and help me narrow down the potential causes.
2. **AWS Pricing Calculator**: Use the `AWS Pricing Calculator` to estimate the costs of the services used during the previous billing cycle. Compare this with the actual costs to identify any discrepancies.
3. **Resource Utilization**: Check the resource utilization of the services used, such as EC2 instances, RDS databases, and S3 buckets. Look for any changes in usage patterns, such as increased CPU utilization or storage usage.
4. **Unbilled Charges**: Review the `Unbilled Charges` section in the Cost and Usage Reports to identify any charges that may not have been included in the previous billing cycle.
5. **Reserved Instances**: Check if there are any Reserved Instances that have been used during the previous billing cycle. If so, review the pricing and usage to ensure that they are being utilized efficiently.

**Potential causes**:

* **Unused or underutilized Reserved Instances**: If Reserved Instances are not being fully utilized, it can lead to increased costs.
* **Overprovisioning**: If resources are overprovisioned, it can result in increased costs due to unused capacity.
* **Unoptimized resource utilization**: If resources are not optimized for the workload, it can lead to increased costs due to inefficient usage.
* **Misconfigured services**: Misconfigured services, such as `S3 buckets` or `RDS databases`, can lead to increased costs due to unnecessary charges.

By investigating these potential causes, I can identify the root cause of the increased AWS bill and take corrective action to optimize costs and reduce expenses.

---
