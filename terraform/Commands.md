# Terraform useful commands

```bash
## Pass variable
terraform apply -var="ec2_instance_name=instance_vm"

## Pass variable files
terraform apply -var-file="dev.tfvars"

## List active resource(s)
terraform state list

## Show the state of particular resource
terraform state show <resource-name>

## Remove a resource from the state only, not on AWS
terraform state rm <resource-name>

## Destroy specific resource
terraform destroy --target=aws_instance.example --auto-approve

## Update resource status inside `.tfstate`
terraform refresh

## Import a resource from the AWS
terraform import aws_instance.new_instance i-08526dsf8dsf8  # <resource-name> <resource-id>

## Grab updated module. Not from cache.
terraform get -update
```
