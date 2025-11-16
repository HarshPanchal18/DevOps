# Brainstorms with LLMs

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

## Production server went down, no alerts received. How will you build a proactive monitoring system?

To build a proactive monitoring system, I would follow these steps:

1. **Define Monitoring Objectives**: Identify the `key performance indicators (KPIs)` and `critical services` that require monitoring. Determine the `desired monitoring frequency, response times, and alert thresholds`.

2. **Choose Monitoring Tools**: Select a combination of monitoring tools that can provide visibility into the production environment, such as:
    * **Infrastructure monitoring**: `Nagios, Prometheus, or Datadog` to monitor server performance, CPU, memory, disk usage, and network traffic.
    * **Application monitoring**: `New Relic, AppDynamics, or Dynatrace` to monitor application performance, latency, and errors.
    * **Log analysis**: `ELK Stack (Elasticsearch, Logstash, Kibana)` or Splunk to analyze log data and detect anomalies.

3. **Set Up Monitoring Agents**: Install `monitoring agents` on production servers to collect data on CPU, memory, disk usage, and network traffic. Configure the agents to send data to the monitoring tools.

4. **Configure Alerting**: Set up alerting mechanisms to notify the operations team of potential issues. Configure alerts based on KPIs, such as:
    * **Threshold-based alerts**: Trigger alerts when CPU usage exceeds 80% or memory usage exceeds 90%.
    * **Anomaly-based alerts**: Detect unusual patterns in log data or network traffic.
    * **Service-based alerts**: Trigger alerts when a critical service becomes unavailable.

5. **Implement On-Call Rotations**: Establish an on-call rotation to ensure that someone is available to respond to alerts 24/7.

6. **Conduct Regular Maintenance**: Schedule regular maintenance tasks, such as:
    * **Agent updates**: Update monitoring agents to ensure they are running with the latest version.
    * **Tool updates**: Update monitoring tools to ensure they are running with the latest version.
    * **Performance testing**: Perform regular performance testing to ensure the monitoring system is not impacting production performance.

7. **Continuously Improve**: Regularly review the monitoring system to identify areas for improvement. Gather feedback from the operations team and make adjustments as needed.

**Proactive Monitoring Strategies**:

* **Real-time monitoring**: Monitor production systems in real-time to detect potential issues before they impact users.
* **Predictive analytics**: Use machine learning algorithms to predict potential issues based on historical data and system trends.
* **Automated remediation**: Automate remediation tasks, such as restarting services or deploying patches, to minimize downtime.

By following these steps and implementing proactive monitoring strategies, you can build a robust monitoring system that detects potential issues before they impact users.

---

## In your docker compose setup, two services can't connect. How do you debug and fix the networking issue?

To debug and fix the networking issue between two services in a Docker Compose setup, follow these steps:

1. **Verify Service Names**: Ensure that the service names in the `docker-compose.yml` file are correct and match the names used in the Docker containers.

2. **Check Network Mode**: Verify that both services are using the same network mode, such as `bridge`, `host`, or `none`. You can check the network mode in the `docker-compose.yml` file or by running `docker inspect` on the containers.

3. **Inspect Network Configuration**: Run `docker network inspect` on the network used by both services to inspect their network configuration. This will show you the IP addresses, ports, and other network settings for each service.

4. **Verify Port Bindings**: Ensure that both services are binding to the correct ports and that the ports are not conflicting. You can check the port bindings in the `docker-compose.yml` file or by running `docker inspect` on the containers.

5. **Check Firewall Rules**: Verify that there are no firewall rules blocking the communication between the two services.

6. **Test Network Connectivity**: Use tools like `telnet` or `nc` to test the network connectivity between the two services. For example, you can run `telnet <service1_ip>:<port>` to test connectivity from service1 to service2.

7. **Check Docker Logs**: Check the Docker logs for both services to see if there are any errors or warnings related to network connectivity.

8. **Try a Different Network Mode**: Try changing the network mode for one of the services to `host` or `none` to see if it resolves the issue.

**Common Networking Issues**:

* **Port conflicts**: Ports used by one service are already in use by another service.
* **IP address conflicts**: IP addresses assigned to services are conflicting with each other.
* **Firewall rules**: Firewall rules are blocking communication between services.
* **Network mode issues**: Services are not using the same network mode or are experiencing issues with the network mode.

**Debugging Tips**:

* **Use `docker-compose up -d` to run services in detached mode**: This allows you to inspect the containers and network configuration without interrupting the services.
* **Use `docker network inspect` to inspect network configuration**: This provides detailed information about the network settings for each service.
* **Use `docker logs` to check service logs**: This helps identify any errors or warnings related to network connectivity.

By following these steps and debugging tips, you can identify and fix the networking issue between two services in your Docker Compose setup.

---

## User report errors mid-rollout. How would you rollback and ensure smooth updates?

To rollback and ensure smooth updates during a deployment, follow these steps:

1. **Identify the issue**: Determine the root cause of the errors and identify the specific deployment that triggered the issue.

2. **Rollback to the previous version**: Rollback to the previous version of the application or service that was working correctly.

3. **Freeze the rollout**: Freeze the rollout process to prevent further deployments until the issue is resolved.

4. **Investigate the issue**: Investigate the issue to determine the cause and identify any potential fixes.

5. **Implement a fix**: Implement a fix or patch to resolve the issue and prevent similar problems in the future.

6. **Test the fix**: Thoroughly test the fix to ensure it resolves the issue and does not introduce new problems.

7. **Resume the rollout**: Once the fix is confirmed, resume the rollout process to deploy the updated version of the application or service.

**Best Practices for Rollbacks**:

* **Use a rolling update strategy**: Use a rolling update strategy to deploy updates to a subset of servers or services, allowing for a smooth transition to the new version.
* **Implement canary releases**: Implement canary releases to deploy a small subset of users to the new version, allowing for testing and validation before rolling out to the entire user base.
* **Use automated rollback**: Use automated rollback mechanisms to quickly revert to a previous version of the application or service in case of an issue.
* **Monitor and log**: Monitor and log all deployments, rollbacks, and updates to ensure that any issues can be quickly identified and resolved.

**Communication**:

* **Notify stakeholders**: Notify stakeholders, including developers, testers, and users, about the issue and the rollback process.
* **Provide updates**: Provide regular updates on the status of the rollback and any subsequent deployments.
* **Communicate changes**: Communicate any changes made to the application or service as a result of the rollback.

By following these steps and best practices, you can ensure a smooth rollback and update process, minimizing downtime and ensuring the reliability of your application or service.

---

## Terraform state file conflict: Two engineers applied changes at the same time. What can break? How do you prevent this?

When two engineers apply changes to the Terraform state file at the same time, it can lead to a conflict. This conflict can break various aspects of the infrastructure, including:

1. **Resource creation**: Terraform may attempt to create resources that already exist, leading to errors and potential data loss.

2. **Resource updates**: Terraform may update resources in ways that are not intended, causing unexpected changes to the infrastructure.

3. **Dependency issues**: Terraform may create dependencies between resources that are not intended, leading to circular dependencies and errors.

4. **State file corruption**: The Terraform state file may become corrupted, leading to errors and potential data loss.

To prevent this conflict, you can implement the following strategies:

1. **Use a lock**: Use a `lock mechanism`, such as `a file lock` or a `distributed lock`, to ensure that only one engineer can apply changes to the Terraform state file at a time.

2. **Use a version control system**: Use a `version control system`, such as Git, to manage changes to the Terraform configuration files. This will allow you to track changes and prevent conflicts.

3. **Use a centralized state file**: Use a `centralized state file`, such as a state file stored in a shared repository, to ensure that all engineers are working with the same state file.

4. **Implement a change management process**: Implement a change management process that requires engineers to submit changes for review and approval before applying them to the Terraform state file.

5. **Use Terraform's built-in locking mechanism**: Terraform provides a built-in locking mechanism that can be used to prevent concurrent changes to the state file.

### **Example of using a lock**

* You can use a file lock to prevent concurrent changes to the Terraform state file.

For example, you can create a file called `terraform.lock` and use a tool like `flock` to lock the file while applying changes.

```bash
flock terraform.lock terraform apply
```

### **Example of using a centralized state file**

You can use a centralized state file stored in a shared repository to ensure that all engineers are working with the same state file.

```bash
terraform init -state=/path/to/state/file
```

### **Example of implementing a change management process**

You can implement a change management process that requires engineers to submit changes for review and approval before applying them to the Terraform state file.

1. **Create a pull request**: Engineers create a pull request to submit their changes for review.

2. **Review and approve changes**: Engineers review and approve the changes before they are applied to the Terraform state file.

3. **Apply changes**: The changes are applied to the Terraform state file after they have been reviewed and approved.

By implementing these strategies, you can prevent conflicts and ensure that changes to the Terraform state file are applied safely and reliably.

---

## A Ansible playbook unexpectedly rebooted all production servers. How will you recover quickly and make sure it never happens again?

To recover quickly and prevent unexpected reboots in the future, follow these steps:

### **Immediate Recovery**

1. **Assess the situation**: Identify the affected servers, their current state, and any potential issues that may have arisen from the unexpected reboot.

2. **Restore services**: Restore services and applications on the affected servers to their previous state, if possible.

3. **Review Ansible logs**: Review Ansible logs to identify the specific playbook and task that caused the unexpected reboot.

4. **Revert changes**: Revert any changes made by the playbook to prevent further issues.

### **Preventing Future Incidents**

1. **Review and update Ansible playbooks**: Review and update Ansible playbooks to ensure that they are safe and reliable.

2. **Implement role-based access control (RBAC)**: Implement role-based access control to restrict access to sensitive tasks and playbooks.

3. **Use Ansible tags**: Use Ansible tags to isolate specific tasks and playbooks, making it easier to test and deploy changes.

4. **Implement a testing environment**: Implement a testing environment to test Ansible playbooks and catch potential issues before they reach production.

5. **Use Ansible's built-in safety features**: Use Ansible's built-in safety features, such as `become` and `become_method`, to ensure that sensitive tasks are executed with elevated privileges.

6. **Implement a change management process**: Implement a change management process that requires approval and testing before deploying changes to production.

7. **Monitor and log Ansible activity**: Monitor and log Ansible activity to detect and respond to any potential issues.

### **Best Practices**

1. **Use a testing environment**: Use a testing environment to test Ansible playbooks and catch potential issues before they reach production.

2. **Implement a change management process**: Implement a change management process that requires approval and testing before deploying changes to production.

3. **Use Ansible's built-in safety features**: Use Ansible's built-in safety features, such as `become` and `become_method`, to ensure that sensitive tasks are executed with elevated privileges.

4. **Monitor and log Ansible activity**: Monitor and log Ansible activity to detect and respond to any potential issues.

### **Example of Implementing a Testing Environment**

You can implement a testing environment using Ansible's `test` module to test playbooks and catch potential issues before they reach production.

```bash
ansible-playbook -i inventory --tags "test" playbook.yml
```

### **Example of Implementing a Change Management Process**

You can implement a change management process using Ansible's `become` and `become_method` features to ensure that sensitive tasks are executed with elevated privileges.

```bash
- name: Update packages
  become: yes
  become_method: sudo
  apt:
    name: python3
    state: present
```

By following these steps and best practices, you can recover quickly from unexpected reboots and prevent similar incidents from happening in the future.

---

## CI/CD Security audit time: You're asked to audit your pipeline's security (Jenkins/GitHub Actions/GitLab CICD). What 5 things would you check first?

To audit the security of a CI/CD pipeline, I would check the following 5 things first:

1. **Access Control and Permissions**:
    * Verify that only authorized personnel have access to the CI/CD pipeline and its configuration.
    * Check that permissions are properly set to prevent unauthorized changes to the pipeline or its configuration.
    * Ensure that access control is implemented using tools like IAM (Identity and Access Management) or RBAC (Role-Based Access Control).

    **Example of auditing access control**:

    ```bash
    aws iam get-user --user-name <username>
    ```

2. **Secret Management**:
    * Identify any sensitive information, such as API keys, credentials, or encryption keys, stored in the pipeline configuration or environment variables.
    * Verify that sensitive information is properly encrypted and stored securely using tools like HashiCorp's Vault or AWS Secrets Manager.
    * Check that sensitive information is not hardcoded or stored in plain text.

    **Example of auditing secret management**:

    ```bash
    aws secretsmanager get-secret-version --secret-id <secret-id> --version-id <version-id>
    ```

3. **Code Quality and Vulnerability Scanning**:
    * Ensure that the pipeline includes code quality and vulnerability scanning tools, such as SonarQube, OWASP ZAP, or Snyk.
    * Verify that these tools are properly configured and integrated into the pipeline.
    * Check that code quality and vulnerability scanning results are properly analyzed and addressed.

    **Example of auditing code quality and vulnerability scanning**:

    ```bash
    sonar-scanner -X
    ```

4. **Pipeline Configuration and Dependencies**:
    * Review the pipeline configuration to ensure that it is properly set up and follows best practices.
    * Verify that dependencies are properly managed and up-to-date.
    * Check that the pipeline configuration does not include any unnecessary or deprecated plugins or tools.

    **Example of auditing pipeline configuration and dependencies**:

5. **Logging and Auditing**:
    * Verify that the pipeline includes proper logging and auditing mechanisms to track changes and detect potential security issues.
    * Check that logs are properly stored and analyzed using tools like Splunk or ELK Stack.
    * Ensure that auditing mechanisms are properly configured and integrated into the pipeline.

By checking these 5 things, you can identify potential security issues and vulnerabilities in your CI/CD pipeline and take corrective action to improve its security.

---

## What happens if multiple StorageClasses are marked as default?

If multiple StorageClasses are marked as default in a Kubernetes cluster, the following occurs:

* When a PersistentVolumeClaim (PVC) is created **without specifying a `storageClassName`**, Kubernetes will use the **most recently created default StorageClass** to provision the storage.
* Having multiple default StorageClasses is technically allowed by Kubernetes, primarily to facilitate seamless migration between storage backends.
* However, this situation is not recommended. It can lead to confusion and unpredictable behavior, as it may not be clear which StorageClass will be used for new PVCs.
* Administrators will typically receive an alert (such as `MultipleDefaultStorageClasses`) indicating that more than one default StorageClass exists, and best practice is to ensure only one StorageClass is marked as default in the cluster.

**In summary:**
If more than one StorageClass is set as default, PVCs without an explicit `storageClassName` will use the most recently created default StorageClass. This can cause ambiguity and should be resolved by ensuring only one default StorageClass is set.

Citations:

* [1] <https://kubernetes.io/docs/tasks/administer-cluster/change-default-storage-class/>
* [2] <https://kubernetes.io/docs/concepts/storage/storage-classes/>
* [3] <https://github.com/kubernetes/kubernetes/issues/110514>
* [4] <https://access.redhat.com/solutions/3586351>
* [5] <https://docs.okd.io/4.18/storage/container_storage_interface/persistent-storage-csi-sc-manage.html>
* [6] <https://docs.openshift.com/rosa/storage/container_storage_interface/persistent-storage-csi-sc-manage.html>
* [7] <https://github.com/pulumi/pulumi-eks/issues/141>
* [8] <https://access.redhat.com/solutions/6779501>

---

## If I delete the storage class directly, does the PVs and PVCs were affected? Why?

Deleting a StorageClass in Kubernetes **does not directly affect existing Persistent Volumes (PVs) or Persistent Volume Claims (PVCs)** that were already provisioned using that StorageClass. Here’s why:

* **PVs and PVCs are independent objects:** Once a PV is provisioned (either statically or dynamically via a StorageClass) and bound to a PVC, their relationship to the StorageClass is essentially historical. The StorageClass is referenced in the PV’s `storageClassName` field, but the PV and PVC continue to function normally even if the StorageClass is deleted.
* **Existing PVs and PVCs remain functional:** Deleting the StorageClass does not delete or unbind existing PVs or PVCs. Applications using those PVCs will continue to have access to their storage as usual.
* **Impact on new provisioning:** The main impact is that **no new PVs can be dynamically provisioned using the deleted StorageClass**. If a user tries to create a new PVC referencing the deleted StorageClass, the request will fail because the StorageClass no longer exists.

**In summary:**

* Deleting a StorageClass does not affect existing PVs or PVCs-they remain available and functional.
* Only new dynamic provisioning using that StorageClass is prevented after its deletion.

Citations:

* [1] <https://kubernetes.io/docs/concepts/storage/persistent-volumes/>
* [2] <https://kubernetes.io/docs/concepts/storage/storage-classes/>
* [3] <https://stackoverflow.com/questions/61187909/how-do-i-change-the-storage-class-of-existing-persistent-volumes>
* [4] <https://www.kubermatic.com/blog/keeping-the-state-of-apps-4-persistentvolumes-and-persistentvolum/>
* [5] <https://kubernetes.io/blog/2024/08/16/kubernetes-1-31-prevent-persistentvolume-leaks-when-deleting-out-of-order/>
* [6] <https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/>
* [7] <https://www.reddit.com/r/kubernetes/comments/bp2xht/can_i_delete_a_storage_class_after_creating/>
* [8] <https://aws.amazon.com/blogs/storage/persistent-storage-for-kubernetes/>

---

## In rollback of deployment, the deployment is rolled back to the previous working version. Right? If yes, then what is the case when the product is about to release for first time?

### **Deployment Rollback**

When rolling back a deployment, the previous working version is restored, usually to resolve issues or revert changes.

### **First-Time Deployment**

In the case of a first-time deployment, there is no previous working version to roll back to. Instead, the deployment is typically done by:

1. **Initial Setup**: Setting up the initial version of the product or application.
2. **First Deployment**: Deploying the initial version to production for the first time.
3. **Post-Deployment Monitoring**: Monitoring the deployment to ensure it's working as expected and making any necessary adjustments.

If issues arise during the first deployment, the team may need to troubleshoot and resolve the problems before proceeding with further deployments.

## **Template Variables in PromQL**

================================

Template variables in PromQL are variables used in metric queries to avoid hard-coding details such as server, application, and sensor names. These variables are listed in dropdown select boxes at the top of a dashboard in Grafana and can be used to change the data displayed in the dashboard.

You can use different types of variables, including **Query** variables, which query Prometheus for a list of metrics, labels, or label values.

The templated variables in Prometheus queries are used to dynamically adjust the time range or interval for queries based on the dashboard's settings. Here are the three templated variables with use cases:

* **`$__interval`**: This variable ensures that your queries automatically adjust to provide an appropriate level of detail based on the selected time range. For example, `rate(http_requests_total[$__interval])` would adapt the query interval to the dashboard's zoom level, showing more granular data when zoomed in and more summarized data when zoomed out.

* **`$__range`**: This variable can be used in queries to adapt the time range of a query to the entire dashboard's time range. For instance, if you're calculating the total number of requests in the selected range, you might use `increase(http_requests_total[$__range])` to get the cumulative increase over the displayed period.

* **`$__rate_interval`**: This variable is particularly useful in cases where you want to calculate rates over a dynamically adjusted time range. For example, using `rate(http_requests_total[$__rate_interval])` ensures that the rate calculation adapts to the dashboard's current resolution, making it suitable for both high and low-resolution data.

These templated variables can be used to create more dynamic and flexible queries that adapt to the dashboard's settings, providing more accurate and relevant data to the user.

* Templated variables in Prometheus queries with brief use cases:

* **`$__interval`**: Adapts query interval to dashboard's zoom level (e.g., `rate(http_requests_total[$__interval])`).
* **`$__range`**: Adjusts query time range to dashboard's time range (e.g., `increase(http_requests_total[$__range])`).
* **`$__rate_interval`**: Calculates rates over dynamically adjusted time range (e.g., `rate(http_requests_total[$__rate_interval])`).

### So what will be the difference between "sum(rate(container_memory_usage_bytes{namespace="production",container="poding"}[$__range])) by(pod) / 1000" and "sum(rate(container_memory_usage_bytes{namespace="production",container="poding"}[1m])) by(pod) / 1000"?

The difference between the two queries is the time range used to calculate the rate.

* The first query `sum(rate(container_memory_usage_bytes{namespace="production",container="poding"}[$__range])) by(pod) / 1000` uses the `__range` templated variable, which adapts to the dashboard's time range. This means the query will automatically adjust the time range based on the dashboard's zoom level.
* The second query `sum(rate(container_memory_usage_bytes{namespace="production",container="poding"}[1m])) by(pod) / 1000` uses a fixed time range of 1 minute (`[1m]`). This means the query will always use a 1-minute time range, regardless of the dashboard's zoom level.

In general, using `__range` allows the query to adapt to different time ranges, while using a fixed time range (like `[1m]`) locks the query to a specific time range.

## What is Pushgateway in prometheus architecture?

### **Pushgateway in Prometheus Architecture**

In the Prometheus architecture, the Pushgateway is an intermediary service used for pushing metrics from quick, ephemeral processes, which would not be caught in Prometheus' regular scraping interval.

Pushgateway allows for:

* Pushing metrics from processes that do not have a stable network identity, such as short-lived jobs or processes running on ephemeral infrastructure.
* Handling metrics from processes that do not have a stable IP address or hostname.
* Providing a way to push metrics from processes that are not running on the same host as the Prometheus server.

The Pushgateway acts as a buffer for metrics, allowing them to be collected and stored even if the original process is no longer running. This ensures that metrics are not lost and can be used for monitoring and alerting purposes.

## Explain SSH tunnels

* **SSH Tunnels: A Brief Overview**

SSH (Secure Shell) tunnels are a feature of the SSH protocol that allows you to securely forward network traffic between a local machine and a remote machine. This is achieved by creating a secure, encrypted connection between the two machines, which can be used to forward traffic on specific ports.

There are two main types of SSH tunnels:

* **Local Port Forwarding**: This involves forwarding a local port on your machine to a remote port on a server. This is useful when you need to access a service on a remote server that is only available on a private interface.
* **Remote Port Forwarding**: This involves forwarding a remote port on a server to a local port on your machine. This is useful when you need to expose a local service to the outside world.

Both types of tunnels can be used to create secure, encrypted connections between machines, and can be useful for a variety of tasks, such as accessing services on private networks or exposing local services to the public internet.

### Give an example

* **Example: Local Port Forwarding**

Suppose you have a web server running on a remote machine at `ssh.example.com` on port 8080, but you can only access the machine via its public IP address. You want to access the web server from your local machine.

You can use SSH to forward the local port 8080 on your machine to the remote port 8080 on `ssh.example.com` using the following command:

```bash
ssh -L 8080:localhost:8080 user@ssh.example.com
```

This will forward any traffic on your local machine's port 8080 to the remote machine's port 8080, allowing you to access the web server from your local machine.

* **Example: Remote Port Forwarding**

Suppose you have a web server running on your local machine on port 8080, but you want to expose it to the outside world. You can use SSH to forward the remote port 8080 on `ssh.example.com` to your local port 8080.

First, you need to configure the SSH server on `ssh.example.com` to allow remote port forwarding by setting `GatewayPorts yes` in the SSH configuration file.

Then, you can use the following command to forward the remote port 8080 on `ssh.example.com` to your local port 8080:

```bash
ssh -R 8080:localhost:8080 user@ssh.example.com
```

This will forward any traffic on `ssh.example.com`'s port 8080 to your local machine's port 8080, allowing you to expose your web server to the outside world.

SSH tunnels can be a bit tricky to understand at first, but they're a powerful tool for securely accessing remote services and exposing local services to the outside world.

## What's the difference between a StatefulSet and a Deployment in Kubernetes?

### **StatefulSet vs Deployment in Kubernetes**

| Feature          | Deployment                           | StatefulSet                        |
|------------------|--------------------------------------|-----------------------------------|
| Pod Identity      | Pods are interchangeable              | Pods have a unique identity       |
| Storage           | Volumes are not persistent            | Volumes are persistent            |
| Scaling           | Easy to scale up/down                | Scaling is more complex           |
| Network Identity  | Pods get a random IP address         | Pods get a stable hostname        |
| Use Cases         | Stateless applications               | Stateful applications              |
| Updates           | Rolling updates are easy             | Rolling updates are more complex  |
| Rollback          | Easy to rollback                     | Rollback is more complex          |
| Pod Management    | Pods can be replaced at any time     | Pods are managed in a specific order |

### **Key Differences**

* **Pod Identity**: In a Deployment, pods are interchangeable and can be replaced at any time. In a StatefulSet, each pod has a unique identity and is managed in a specific order.
* **Storage**: Deployments do not provide persistent storage, while StatefulSets provide persistent storage for each pod.
* **Scaling**: Scaling a Deployment is straightforward, while scaling a StatefulSet is more complex due to the unique identity of each pod.
* **Network Identity**: In a Deployment, pods get a random IP address, while in a StatefulSet, pods get a stable hostname that can be used to access them.
* **Use Cases**: Deployments are typically used for stateless applications, while StatefulSets are used for stateful applications that require persistent storage and unique identities.
* **Updates and Rollbacks**: Deployments support easy rolling updates and rollbacks, while StatefulSets have more complex update and rollback processes due to the unique identities of the pods.

## What is the difference between a LoadBalancer and a Gateway in Kubernetes?

| Feature            | LoadBalancer                            | Gateway                                         |
|--------------------|-----------------------------------------|-------------------------------------------------|
| Purpose            | Exposes a service to the internet       | Manages traffic between services                |
| Layer              | Works at Layer 4 (Transport Layer)      | Works at Layer 7 (Application Layer)            |
| Configuration      | Simple configuration, just a service    | More complex, involves routing rules            |
| Use Cases          | External access to a service            | API Gateway, Ingress Controller                 |
| Protocols          | Supports TCP/UDP protocols              | Supports HTTP/HTTPS protocols                   |
| Load Balancing     | Provides load balancing for services    | Can provide advanced routing and load balancing |
| Traffic Management | Limited traffic management capabilities | Advanced traffic management capabilities        |
| Security           | Basic security features                 | Advanced security features                      |
| Monitoring         | Basic monitoring capabilities           | Advanced monitoring capabilities                |

### **Key Points**

* **Purpose**: A LoadBalancer is primarily used to expose a service to the internet, while a Gateway is used to manage traffic between services within the cluster.
* **Layer**: LoadBalancers operate at Layer 4 (Transport Layer), while Gateways operate at Layer 7 (Application Layer).
* **Configuration**: LoadBalancers have a simpler configuration, typically just requiring a service definition, while Gateways involve more complex routing rules and configurations.
* **Use Cases**: LoadBalancers are used for external access to services, while Gateways are used for API management, Ingress control, and advanced traffic routing.
* **Protocols**: LoadBalancers support TCP/UDP protocols, while Gateways primarily support HTTP/HTTPS protocols.
* **Load Balancing**: LoadBalancers provide basic load balancing for services, while Gateways can provide advanced routing and load balancing capabilities.
* **Traffic Management**: LoadBalancers have limited traffic management capabilities, while Gateways offer advanced traffic management features such as request routing, rate limiting, and authentication.
* **Security**: LoadBalancers provide basic security features, while Gateways offer advanced security features such as TLS termination, authentication, and authorization.
* **Monitoring**: LoadBalancers have basic monitoring capabilities, while Gateways provide advanced monitoring features such as request tracing, metrics collection, and logging.

### **Use Cases**

* **LoadBalancer**: Use a LoadBalancer when you need to `expose a service to the internet` and require basic load balancing capabilities.
* **Gateway**: Use a Gateway when you need `advanced traffic management`, `API management`, or `Ingress control` within your Kubernetes cluster.

## How to reclaim the PV after the pod is deleted?

To reclaim a Persistent Volume (PV) after its associated Pod is deleted, you typically need to focus on how the Persistent Volume Claim (PVC) and the PV reclaim policy are managed:

* **Deletion of Pod does not remove PVC or PV** by default. The PVC remains bound to the PV, preserving the data unless the PVC itself is deleted. Thus, deleting a pod that uses a PVC will normally allow the PVC and PV to remain available, so the data is retained for reuse by a new pod.

* **Reclaim Policy Matters:** The PV has a `persistentVolumeReclaimPolicy` which controls what happens when the PVC is deleted:
  * If the reclaim policy is **Delete**, then deleting the PVC will delete the PV and its underlying storage.
  * If the reclaim policy is **Retain**, the PV is not deleted when the PVC is deleted. Instead, the PV enters a "Released" state, where the data is preserved but the volume is not yet available for reuse.

* **Steps to reclaim a PV after Pod deletion (when PVC is deleted or needs to be reused):**

  1. **If PVC still exists:** Simply recreate or restart the pod with the same PVC. The PV is normally automatically mounted again.

  2. **If PVC was deleted but PV is in Released state (Retain policy):**
     * Manually remove the `claimRef` from the PV specification (edit the PV resource), making the PV’s status "Available".
     * Create a new PVC that matches the PV's specifications.
     * The new PVC will bind to the PV, allowing a new pod to use the reclaimed volume and access existing data.

  3. **If reclaim policy is Delete:** Data and PV are removed once PVC is deleted. You cannot reclaim data in this case unless you restore from backup.

* **Example of manual reclaim steps for Retain policy:**

   ```bash
   kubectl edit pv
   ```

   Remove the `claimRef` section, save the PV, which changes its status to Available. Then recreate a PVC with matching specifications, which will bind to that PV again.

This manual process is essential if the PVC was deleted accidentally but you want to reuse the underlying PV and keep your data intact.

In summary: If you only deleted the pod, normally no extra step is needed because PVC and PV remain bound and data intact. If PVC is deleted with Retain policy on PV, manual editing of the PV claim reference allows reclaiming it. If the reclaim policy is Delete, the PV and data are removed when PVC is deleted, so reclamation is not possible without backup.

[1] <https://github.com/kubernetes/kubernetes/issues/96859>
[2] <https://www.linode.com/community/questions/20215/how-to-re-attach-persistent-volume-to-pod-when-claim-is-deleted>
[3] <https://stackoverflow.com/questions/58418093/state-of-pv-pvc-after-pod-is-deleted-in-kubernetes>
[4] <https://access.redhat.com/solutions/7039096>
[5] <https://portworx.com/tutorial-kubernetes-persistent-volumes/>
[6] <https://www.reddit.com/r/kubernetes/comments/1if48li/accidently_deleted_pvs_now_in_terminating_state/>
[7] <https://kubernetes.io/docs/concepts/storage/persistent-volumes/>
[8] <https://docs.oracle.com/en/engineered-systems/private-cloud-appliance/3.0-latest/oke/oke-pv-del-ret.html>
[9] <https://kubernetes.io/docs/tasks/administer-cluster/change-pv-reclaim-policy/>
[10] <https://platform9.com/kb/kubernetes/recover-persistent-volumes-from--terminating--state>

### What steps are needed to manually reattach a PV to a new PVC?

To manually reattach a Persistent Volume (PV) to a new Persistent Volume Claim (PVC), follow these key steps:

1. **Check PV Status**: Ensure the PV is in the "Released" status, meaning its previous claim was deleted but data still exists, and the reclaim policy is "Retain".

2. **Remove the `claimRef` from the PV**:
   * Edit the PV resource using:

     ```bash
     kubectl edit pv
     ```

   * In the PV spec, delete the `claimRef` section. This releases the PV so it becomes available for binding again. Save and exit.

3. **Create a new PVC**:
   * Define a new PVC YAML that matches the storage class, access modes, and capacity of the PV you want to reclaim.
   * Apply the new PVC:

     ```bash
     kubectl apply -f
     ```

4. **Verify Binding**:
   * Check that the new PVC is bound to the existing PV by:

     ```bash
     kubectl get pvc
     kubectl get pv
     ```

   The PV should now show status "Bound" to your new PVC.

5. **Optional - Edit PV to Bind to New PVC (Less common)**:
    * If automatic binding does not occur, you can manually assign the PVC by editing the PV:

      ```bash
      kubectl edit pv
      ```

    * Add a `claimRef` section pointing to your new PVC's name and namespace, including the PVC’s UID (obtained by `kubectl get pvc  -o yaml | grep uid`).
    * Save the PV. This manually links the PV to your new PVC.

6. **Use PVC in a Pod**:
   * Reference the new PVC in your Pod spec's volumes to access the reclaimed PV.

This manual process releases the PV from its old claim and allows it to be claimed by a new PVC so that existing data can be preserved and reused.

References with detailed examples and steps confirm this approach:

* Remove `claimRef` to make PV Available, then create matching PVC to bind.
* Optionally manually edit PV's `claimRef` to point to new PVC with matching UID.
* Verify reclaim policy is "Retain" to avoid automatic deletion on claim removal.

This is a common Kubernetes administrative task to recover PVs after accidental PVC deletion or Pod removal.

[1] <https://www.linode.com/community/questions/20215/how-to-re-attach-persistent-volume-to-pod-when-claim-is-deleted>
[2] <https://portworx.com/tutorial-kubernetes-persistent-volumes/>
[3] <https://access.redhat.com/solutions/4651451>
[4] <https://www.groundcover.com/blog/kubernetes-pvc>
[5] <https://stackoverflow.com/questions/56368453/how-to-reattach-released-persistentvolume-in-kubernetes>
[6] <https://kubernetes.io/docs/concepts/storage/persistent-volumes/>
[7] <https://komodor.com/learn/kubernetes-pvc-guide-basic-tutorial-and-troubleshooting-tips/>

## How to Clean Up Old Containers and Images in Your Kubernetes Cluster

### Container Images

Kubernetes has a built-in garabage collection system that can clean up unused images. It's managed by Kubelet, the Kubernetes worker process that runs on each node.

Kubelet automatically monitors unused images and will remove them [periodically](https://kubernetes.io/docs/concepts/architecture/garbage-collection/#containers-images). Deletion decisions are made by assessing the image's disk usage and the time at which it was last used. A large image that has been unused for a week will usually be cleaned up before a small one that was used yesterday.

You can customise when garbage collection runs by specifying high and low thresholds for disk usage. Disk usage above the "high" threshold will trigger garbage collection. The procedure will try to reduce disk usage down to the "low" threshold.

The thresholds are defined using two Kubelet flags:

* `image-gc-high-threshold` - Sets the high threshold; defaults to 85%.
* `image-gc-low-threshold` - Sets the low threshold; defaults to 80%.

These settings should already be active in your cluster. Kubelet will try to bring disk usage down to 80% after it becomes 85% full.

You can set Kubectl flags in file `kubeadm-flags.env`.

```text
/var/lib/kubelet/kubeadm-flags.env
```

```conf
KUBELET_KUBEADM_ARGS="--image-gc-high-threshold=60 --image-gc-low-threshold=50"
```

After editing the file, restart Kubectl:

```bash
systemctl daemon-reload
systemctl restart kubelet
```

### Clearing old containers

Kubelet also handles clean up of redundant containers. Any containers which are stopped or unidentified will be candidates for removal.

You can grant old containers a grace period before deletion by defining a minimum container age. Additional flags let you control the total number of dead containers allowed to exist in a single pod and on the node:

* `maximum-dead-containers` - Maximum number of old containers to retain. When set to -1 (the default), no limit applies.
* `maximum-dead-containers-per-container` - Set the number of older instances to be retained on a per-container basis. If a container is replaced with a newer instance, this many older versions will be allowed to remain.
* `minimum-container-ttl-duration` - Garbage collection grace period for dead containers. Once a container is this many minutes old, it becomes eligible for garbage collection. The default value of 0 means no grace period applies.

You can configure these settings with Kubelet flags using the same procedure as described above.

> [!CAUTION]
> Kubernetes warns against performing external garbage collection. Don't manually delete resources, either using cluster management APIs or third-party tools. This risks creating an inconsistent state which could impact Kubelet's operation.

## How Kubernetes Calculates Access Permissions Using RBAC Rules

RBAC, or Role Based Access Control, is a critical concept every DevOps and Cloud Engineer must understand. It defines who can perform what actions on which resources.

Whether managing Kubernetes, cloud accounts, or CI/CD pipelines, it brings structure to access control, makes permissions predictable, and helps teams manage security at scale.

When a user, service account, or process tries to perform an action (verb) on a resource (like deployments) in a namespace, Kubernetes uses the following flow to determine if the action is allowed:

![RBAC Workflow](/Kubernetes/assets/rbac-workflow.jpg)

1. API Server Receives the Request
    The request could be: GET /apis/apps/v1/namespaces/dev/deployments/nginx-deploy

    It includes:

    * Verb: get
    * Resource: deployments
    * Namespace: dev
    * User identity

2. Authentication
    The API server authenticates the request using one of the supported methods:

    * Client certificate authentication from the kube-apiserver configuration
    * Bearer tokens (including service account tokens)
    * OIDC tokens configured with an identity provider

    For this example, the identity resolved is:
    `User = <harsh@example.com>`

3. Authorization
    The RBAC authorizer processes the authenticated identity and evaluates it against:

    RoleBindings and ClusterRoleBindings present in etcd.

    Corresponding Roles or ClusterRoles defined in the cluster.

    ```yaml
    # Role allowing get on deployments in namespace dev

    kind: Role
    metadata:
    namespace: dev
    name: view-deployments
    rules:
    - apiGroups: ["apps"]
      resources: ["deployments"]
      verbs: ["get", "list"]
    ```

    ```yaml
    # RoleBinding assigning above role to user from techopsexamples

    kind: RoleBinding
    metadata:
    name: deployment-reader
    namespace: dev
    subjects:
    - kind: User
      name: <govardhana.mk@techopsexamples.com>
    roleRef:
      kind: Role
      name: view-deployments
      apiGroup: rbac.authorization.k8s.io
    ```

4. Match Rules
    The RBAC authorizer iterates through all applicable rules in the matched Roles or ClusterRoles. Checks whether any rule allows the verb on the resource in the given namespace

    Each rule contains:

    * verbs (e.g., get, list)
    * resources (e.g., deployments)
    * apiGroups (e.g., apps)
    * resourceNames (optional, e.g., only certain deployments)

5. Decision
    If any rule matches, the RBAC authorizer grants access

    If no rule matches, the API server returns 403 Forbidden

    Test the calculation:

    ```bash
    kubectl auth can-i get deployments --as <govardhana.mk@techopsexamples.com> --namespace dev
    ```

## How To Run Kubernetes in Air Gapped Networks

For someone who is new to air gap environments, it is a security measure where a network or system is physically isolated from other networks, including the internet, to prevent unauthorized access.

In air gapped environments, you cannot pull container images on demand or reach public Helm repositories. Every artifact must be explicitly packaged, shipped, and verified. The best combination for this is Talos OS and Zarf.

* Talos OS is a minimal, immutable OS for Kubernetes with no shell or SSH.
* Zarf packages container images, charts, and files into air gap-ready bundles.

Implementation Architecture

1. Package Creation:

    In a network connected setting, 𝘻𝘢𝘳𝘧 𝘱𝘢𝘤𝘬𝘢𝘨𝘦 𝘤𝘳𝘦𝘢𝘵𝘦 is used to assemble Zarf packages, bundling all essential deployment artifacts.

2. Secure Transfer:

    These Zarf packages (.tar.zst) are then securely conveyed to the air gapped zone utilizing secure transfer methods, ensuring the environment where Talos operates is safeguarded.

3. Deployment by Talos:

    Use zarf package deploy from a Talos compatible host.

    Talos API unpacks the package, loads images via containerd, and starts kubelet to create pods.

### Why This Works?

* Talos ensures immutable, locked down nodes.
* Zarf solves dependency and packaging challenges.
* No internet needed at runtime.

## How To Perform Git clone in Kubernetes Pod deployment

This serves as an ideal solution if you store application code in Git version control and would like to pull the latest code during deployment without rebuilding container image. A kubernetes feature which allows us to perform this operation is Init Containers.

`Init Containers` are specialized type of containers that run before application containers in a Pod. These containers can contain utilities or setup scripts not present in an application image. There is nothing so unique about Init containers as they can be specified in the Pod specification alongside the containers array.

### Requirements

* `alpine/git`: Init container for `git pull`.
* `nginx`: Runs nginx web server

Create a namespace for the project

```bash
kubectl create ns helloworld
```

Retrieve nginx pod YAML and modify to add `initContainer`. Below is a pod YAML.

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx-helloworld
  name: nginx-helloworld
spec:
  containers:
  - image: nginx
    name: nginx-helloworld
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
```

Update the manifest as below:

```diff
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx-helloworld
  name: nginx-helloworld
spec:
  containers:
  - image: nginx
    name: nginx-helloworld
+    ports:
+    - containerPort: 80
+    volumeMounts:
+    - mountPath: "/usr/share/nginx/html"
+      name: www-data
-    resources: {}
+  initContainers:
+  - name: git-cloner
+    image: alpine/git
+    args:
+        - clone
+        - --single-branch
+        - --
+        - https://github.com/jmutai/hello-world-nginx.git
+        - /data
+    volumeMounts: # Sharing between containers
+    - mountPath: /data
+      name: www-data
+  volumes:
+  - name: www-data
+    emptyDir: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
```

Apply the file to deploy pods.

```bash
kubectl apply -f pod-nginx-helloworld.yml
```

## Scale down kubernetes deployments to 0 and scale back to original number of replica sets

[Query](https://stackoverflow.com/questions/64133011/scale-down-kubernetes-deployments-to-0-and-scale-back-to-original-number-of-repl)

```bash
# annotate first
kubectl get deploy -o jsonpath='{range .items[*]}{"kubectl annotate --overwrite deploy "}{@.metadata.name}{" previous-size="}{@.spec.replicas}{" \n"}{end}' | sh

# scale to 0
kubectl scale --replicas=0 $(kubectl get deploy -o name)

## scaleback to the previous size
kubectl get deploy -o jsonpath='{range .items[*]}{"kubectl scale deploy "}{@.metadata.name}{" --replicas="}{.metadata.annotations.previous-size}{"\n"}{end}' | sh
```

## What is ambassador-pattern in Kubernetes? How it is differed from the sidecar-pattern?

The **Ambassador** and **Sidecar** patterns are both multi-container Pod patterns in Kubernetes, but they serve distinct roles in application architecture. **The ambassador pattern acts as a proxy for external communication, while the sidecar pattern augments or extends the main application container’s functionality within the Pod.**

### **Ambassador Pattern**

* Functions as a `proxy container` that handles communication between the main application container and external services.
* Typically used to manage outbound connections, such as routing traffic to external APIs or databases, abstracting away network complexities from the main application.
* The ambassador container is responsible for protocol translation, authentication, or traffic management for external interactions.

### **Sidecar Pattern**

* Involves a secondary container that runs alongside the main application container within the same Pod.
* Enhances the main application by providing supporting features like logging, monitoring, configuration updates, or security.
* Sidecars often intercept and manage internal traffic, or add operational capabilities without modifying the application code.

### Key Differences

| Aspect                | Ambassador Pattern                  | Sidecar Pattern                        | Citations                                               |
|-----------------------|-------------------------------------|----------------------------------------|---------------------------------------------------------|
| Main Purpose          | Proxy for external communication    | Augment internal app functionality     |  (Valavandan et al., 2023; Salcedo-Navarro et al., 2025)|
| Traffic Direction     | Outbound (to external services)     | Inbound/outbound (internal/external)   |  (Valavandan et al., 2023; Salcedo-Navarro et al., 2025)|
| Example Use Cases     | API gateway, DB proxy               | Logging, monitoring, service mesh      |  (Valavandan et al., 2023; Salcedo-Navarro et al., 2025)|
| Application Coupling  | Loosely coupled to app container    | Tightly coupled to app container       |  (Valavandan et al., 2023; Salcedo-Navarro et al., 2025)|

### Functional Differences

**Sidecar Pattern**: Primarily used to add operational features (e.g., logging, monitoring, security, or storage management) to the main application container by intercepting and managing traffic or providing auxiliary services within the same Pod. Sidecars are tightly coupled to the application and often handle internal concerns.

**Ambassador Pattern**: Functions as a proxy for external communication, managing outbound connections from the main application to external services. Ambassadors abstract away network complexities and are loosely coupled, focusing on external service integration.

### Example YAML

#### Sidecar Pattern Example

A sidecar container runs alongside the main application container, often providing logging, monitoring, or proxying services.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: sidecar-example
spec:
  containers:
    - name: main-app
      image: nginx
    - name: sidecar-logger
      image: busybox
      args: [/bin/sh, -c, 'while true; do echo Sidecar logging; sleep 5; done']
```

Explanation:

* `main-app` is the primary application (nginx).
* `sidecar-logger` is a sidecar container that continuously logs messages, demonstrating how sidecars can add auxiliary functionality.

#### Ambassador Pattern Example

An ambassador container acts as a proxy between the main application and an external service (e.g., a database or API).

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ambassador-example
spec:
  containers:
    - name: main-app
      image: my-app-image
      env:
        - name: DB_HOST
          value: "localhost"
    - name: ambassador-proxy
      image: envoyproxy/envoy
      args: ["-c", "/etc/envoy/envoy.yaml"]
      ports:
        - containerPort: 3306
```

Explanation:

* `main-app` connects to a database at `localhost`, but the actual connection is handled by the `ambassador-proxy` (e.g., Envoy), which forwards traffic to the real database endpoint.
* The ambassador abstracts external service details from the main app.

### How Sidecar and Ambassador Patterns Improve Communication?

#### Sidecar Pattern

* **Separation of Concerns**: Sidecar proxies (e.g., Envoy) decouple operational features like security, networking, and monitoring from the application logic, allowing microservices to focus solely on business functionality.

* **Traffic Management**: Sidecars can intercept, route, and monitor inter-service traffic, enabling features such as endpoint access control, request rate limiting, logging, and mutual TLS (mTLS) for secure communication.

* **Modularity and Reusability**: By abstracting cross-cutting concerns, sidecars make it easier to apply consistent policies across services and reuse communication logic.

#### Ambassador Pattern

* **External Communication Proxy**: Ambassador containers act as proxies for outbound connections, managing and abstracting communication with external services or APIs. This simplifies integration and centralizes external traffic management.

* **Enhanced Flexibility**: Like sidecars, ambassadors can be configured to handle protocol translation, authentication, and traffic routing, further improving the robustness of microservices communication.

#### Performance Considerations

* **Overhead**: While these patterns provide significant benefits, sidecar proxies can introduce latency and resource overhead, especially in large-scale deployments. Studies report increased request latency and CPU usage depending on the complexity of policies enforced by sidecars.

* **Optimization Needed**: Careful configuration and monitoring are necessary to balance the benefits of improved communication with potential performance impacts.

### Conclusion

The ambassador pattern is best for **managing external service communication**, while the sidecar pattern is ideal for **extending or supporting the main application’s internal operations**. Both patterns enhance modularity and flexibility in Kubernetes, but their use cases and integration points differ significantly.

Sidecar and ambassador patterns are not interchangeable in Kubernetes because they address different architectural needs. Choosing the right pattern depends on whether the requirement is internal operational support (sidecar) or external service communication (ambassador).

Sidecar and ambassador patterns are effective tools for improving microservices communication in Kubernetes by modularizing operational concerns and enabling advanced traffic management. However, their use should be balanced with awareness of potential performance trade-offs.

### References

Valavandan, R., Gothandapani, B., Gnanavel, A., Ramamurthy, N., Balakrishnan, M., Gnanavel, S., & Ramamurthy, S. (2023). Unleashing the Power of Kubernetes: Embracing Openness and Vendor Neutrality for Agile Container Development in an Evolving Landscape. _International Journal of Research Publication and Reviews_. <https://doi.org/10.55248/gengpi.4.523.44101>

Salcedo-Navarro, A., García-Pineda, M., & Gutiérrez-Aguado, J. (2025). K8sidecar: A Modular Kubernetes Chain of Sidecar Proxies for Microservices and Serverless Architectures. _Software: Practice and Experience_. <https://doi.org/10.1002/spe.3423>

Sahu, P., Zheng, L., Bueso, M., Wei, S., Yadwadkar, N., & Tiwari, M. (2023). Sidecars on the Central Lane: Impact of Network Proxies on Microservices. ArXiv, abs/2306.15792. <https://doi.org/10.48550/arXiv.2306.15792>

Maia, J., & Correia, F. (2022). Service Mesh Patterns. Proceedings of the 27th European Conference on Pattern Languages of Programs. <https://doi.org/10.1145/3551902.3551962>

Kratzke, N. (2018). A Brief History of Cloud Application Architectures. Applied Sciences. <https://doi.org/10.20944/PREPRINTS201807.0276.V1>

## What is supply chain attack?

A supply chain attack occurs when an attacker targets a company's or organization's supply chain, often by compromising a third-party vendor or supplier, to gain access to sensitive information or disrupt operations. This can happen when a vendor's system is breached, allowing the attacker to inject malicious code or steal sensitive data, which is then used to attack the company's own systems or compromise its customers.

**Examples of supply chain attacks include:**

* Malware being introduced into a company's software or hardware through a compromised vendor
* Sensitive data being stolen from a vendor's system and used to conduct targeted attacks
* A vendor's system being used to distribute malware to a company's customers

In the context of the provided text, Gartner predicts that 45% of global organizations will be impacted by a supply chain attack by 2025, highlighting the growing risk of these types of attacks.

## Do I need virtual-service for each microservices?

Yes, you typically need to create a **Gateway** and **VirtualService** for each microservice that you want to expose externally or route traffic to within the Istio service mesh. However, the exact setup depends on your architecture and requirements. Here's a breakdown:

### When to Create a Gateway

* **External Access**: If a microservice needs to be accessed from outside the cluster (e.g., by users or external systems), you need a **Gateway** to expose it through Istio's ingress gateway.
* **Shared Gateway**: You can use a single Gateway for multiple microservices by defining multiple
* **VirtualServices** that route traffic to different services based on hostnames or URI prefixes.

### When to Create a VirtualService

* **Traffic Routing**: Each microservice typically needs a **VirtualService** to define how traffic is routed to it. This includes:
* Matching incoming requests (e.g., by URI or headers).
* Specifying the destination service and port.
* **Advanced Features**: If you want to implement features like traffic splitting, retries, timeouts, or fault injection, you need a VirtualService for each microservice.

### Example Scenarios

1. **Single Gateway for All Microservices**:
    * Create one Gateway (e.g., `app-gateway`) and multiple VirtualServices for each microservice.
    * Use URI prefixes or hostnames in the VirtualServices to route traffic to the appropriate microservice.

   Example:

    ```yaml
    # Gateway
    apiVersion: networking.istio.io/v1beta1
    kind: Gateway
    metadata:
        name: app-gateway
    spec:
        selector:
        istio: ingressgateway
        servers:
        - port:
            number: 80
            name: http
            protocol: HTTP
        hosts:
        - "*"

    ---

    # VirtualService for login-service
    apiVersion: networking.istio.io/v1beta1
    kind: VirtualService
    metadata:
        name: login-route
    spec:
        hosts:
        - "*"
        gateways:
        - app-gateway
        http:
        - match:
            - uri:
                prefix: /login
        route:
        - destination:
            host: login-service
            port:
                number: 80

    ---

    # VirtualService for dashboard-service
    apiVersion: networking.istio.io/v1beta1
    kind: VirtualService
    metadata:
        name: dashboard-route
    spec:
        hosts:
        - "*"
        gateways:
        - app-gateway
        http:
        - match:
            - uri:
                prefix: /dashboard
        route:
        - destination:
            host: dashboard-service
            port:
                number: 80
    ```

2. **Separate Gateway for Each Microservice**:
    * If each microservice needs its own external entry point, create a separate Gateway and VirtualService for each.

    Example:

    ```yaml
    # Gateway for login-service
    apiVersion: networking.istio.io/v1beta1
    kind: Gateway
    metadata:
        name: login-gateway
    spec:
        selector:
        istio: ingressgateway
        servers:
        - port:
            number: 80
            name: http
            protocol: HTTP
        hosts:
        - "login.example.com"

    ---

    # VirtualService for login-service
    apiVersion: networking.istio.io/v1beta1
    kind: VirtualService
    metadata:
        name: login-route
    spec:
        hosts:
        - "login.example.com"
        gateways:
        - login-gateway
        http:
        - route:
        - destination:
            host: login-service
            port:
                number: 80
    ```

### Best Practices

* **Shared Gateway**: Use a single Gateway for simplicity unless you have specific reasons to separate them (e.g., different domains or security policies).
* **Namespace Isolation**: Deploy microservices and their corresponding Istio resources (Gateway, VirtualService) in separate namespaces for better organization and isolation.
* **DNS and Hostnames**: Use hostnames (e.g., `login.example.com`) in your Gateway and VirtualService for better clarity and scalability.

Let me know if you need help setting up specific configurations!
