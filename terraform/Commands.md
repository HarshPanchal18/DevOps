# Terraform useful commands

## List active resource(s)

```bash
terraform state list
```

## Show the state of particular resource

```bash
terraform state show <resource-name>
```

## Remove a resource from the state only, not on AWS

```bash
terraform state rm <resource-name>
```

## Destroy specific resource

```bash
terraform destroy --target=aws_instance.example --auto-approve
```

## Update resource status inside `.tfstate`

```bash
terraform refresh
```

## Import a resource from the AWS

```bash
terraform import <resource-name> <resource-id>
terraform import aws_instance.new_instance i-08526dsf8dsf8
```

### Verify via

```bash
terraform state list
```
