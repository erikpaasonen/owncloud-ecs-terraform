# owncloud-ecs-terraform
Personal OwnCloud file sync/share solution featuring Terraform infra-as-code and eventually deploying to AWS ECS Fargate

## How to Use This Repo

The `terraform` directory is where the action is.

1. Set up an AWS account and configure CLI authentication (default profile)
1. Install [Terraform](https://terraform.io)
1. Clone this repo locally
1. `cd` into the `terraform` directory
1. Run `terraform init`
1. Run `terraform plan` to see a preview of what the code will create
1. Run `terraform apply` to create all the things

When done having fun, run `terraform destroy` and Terraform will delete/destroy everything that it created in your AWS account.
