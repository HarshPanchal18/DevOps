# Terraform

## Concepts

- `Providers`: Plugins that let Terraform interact with cloud platforms like AWS, Azure, GCP, etc.
- `Resources`: The infrastructure components (like EC2, S3, VPC) that Terraform manages.
- `Variables`: To make scripts dynamic and reusable.
- `State`: Terraform maintains a .tfstate file to track real infrastructure.
- `Modules`: Grouping resources into reusable components.

## Best Practices

- Use variables in `variables.tf`
- Set outputs in `outputs.tf`
- Split configs into logical files (`provider.tf`, `main.tf`, etc.)
- Use `.tfvars` files for environment-specific values

## Before Going Cloud

If using AWS, create a separate IAM user for Terraform with appropriate permissions.

Store credentials using:

```bash
aws configure
```

## Tips

### If you ever change providers but have existing resources, Terraform’s `.tfstate` still remembers the old provider config. To fix mismatches

```bash
terraform state replace-provider \
    registry.terraform.io/hashicorp/aws \
    registry.terraform.io/hashicorp/aws
```

This tells Terraform:

>"Hey, update all the resources using the `aws.east` alias to now use the default aws provider."

- Verify via

    ```bash
    terraform plan
    ```

## Terraform Environment

A Terraform environment is a configuration setup that allows users to consistently manage and deploy infrastructure resources across various stages, such as development, testing, and production.

It represents a logical grouping of resources that serve a shared purpose or correspond to a specific phase in the development lifecycle.

Each environment functions as an isolated "world," allowing you to deploy and manage infrastructure safely without impacting other environments.

## Terraform Workspace

Terraform workspaces enable us to manage multiple deployments of the same configuration.

The information about all the resources managed by Terraform is stored in a **state file**. It is important to store this state file in a secure location. Every Terraform run is associated with a state file for validation and reference purposes. Any modifications to the Terraform configuration, planned or applied, are always validated first with references in the state files, and the execution result is updated back to it.

If you are not consciously using any workspace, all of this already happens in a default workspace. Workspaces help you isolate independent deployments of the same Terraform config while using the same state file.

### What is the difference between the Terraform environment and the workspace?

A Terraform environment typically refers to the **overall setup of your infrastructure**, including all configurations and resources that define it.

A workspace, on the other hand, is a **named state file** that enables you to **manage multiple isolated instances of the same infrastructure configuration.**

By keeping state files separate, workspaces help prevent conflicts and simplify the management of distinct deployments.

`default` workspace cannot be deleted.

Create a new workspace:

```bash
terraform workspace new dev
```

### Manage variables with terraform workspace

For each environment, you can declare a `tfvars` file:

- **dev.tfvars**
- **test.tfvars**
- **stage.tfvars**
- **prod.tfvars**

Apply resources like this:

```bash
terraform workspace select dev
terraform apply -var-file=dev.tfvars
```

You can also conditionally assign values to different parameters based on the workspace.

```terraform
locals {
    instance_type = terraform.workspace == "prod" ? "t2.large" : "t2.micro"
}
```

As a best practice, wherever possible, you should assign default values to your variables, especially when you are working with workspaces, to avoid repeating code in the tfvars files. This will make your configuration less error-prone.

### Workspace interpolation

Terraform provides an interpolation sequence to reference the value of the currently selected workspace, such as `${terraform.workspace}`.

E.x.

```terraform
variable "name_tag" {
    type        = string
    description = "Name of the EC2 instance"
    default     = "EC2"
}

resource "aws_instance" "my_vm" {
    ami           = var.ami
    instance_type = var.instance_type

    tags = {
        name = format("%s_%s", var.name_tag, terraform.workspace)  # concatenate multiple strings to for a valid name value
    }
}
```

```bash
terraform workspace select default
terraform apply
terraform workspace select dev
terraform apply
```

Here, two EC2 instances (**EC2_default**, **EC2_dev**) were created using the same configuration but in different workspaces.

## QnA

### What is the primary purpose of HCL?

> To define resources and configurations in a human readable format.

### What does the `.terraform` directory contain?

> Provider plugins and metadata.

### What is the default file created by terraform the store the execution plan?

> `plan.out`

### What is the purpose of `root_block_device` block in a terrafrom resource definition?

> To define the configuration of the root storage volume for an instance.

### What is the correct way to import an existing S3 bucket into Terraform?

> Use the `terraform import` command with the resource and bucket name.

### What is the function of terraform `fmt`?

> Reformats configuration files to canonical HCL style.

### Git branches vs. Terraform workspace

Git branches maintain various versioned copies of the same configuration used to develop new features or Terraform modules, whereas workspaces completely depend upon the state file maintained in the remote backend by Terraform.
