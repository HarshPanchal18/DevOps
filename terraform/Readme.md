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
