# terraform-lambdas-api-gateway-cloudfront
Example terraform/terragrunt scripts for lambdas, api-gateway and cloudfront

## Install Terraform & terragrunt

```
brew install terraform terragrunt
```

## Install AWS CLI

Instructions here <https://docs.aws.amazon.com/cli/latest/userguide/install-macos.html>



## Write a Terragrunt file

Save the below to `deployDev.hcl` at the root of the project, change the account id to your one.

If you have multiple profiles you'll need to change the `profile` key as well

If you just want to run of the default profile all the time you can safely remove all the profile stuff from the code, it'll just pick up the default.

```
remote_state {
  backend = "s3"
  config = {
    profile = "default"
    region  = "eu-west-2"
    bucket  = "example-config"
    key     = "my-example-terraformstate"
  }
}


inputs = {
  profile                 = "personal"
  public_bucket_name      = "my-example-public-bucket"
  private_bucket_name     = "my-example-private-bucket"
  lambda_edge_bucket_name = "my-example-lambda-edge-bucket"
  region                  = "eu-west-2"
  edge_region             = "us-east-1"
  account_id              = "YOUR_ACCOUNT_ID"
  project_prefix          = "my-example"
}

```

## Run Deployment

Run the deployment

```
TERRAGRUNT_CONFIG=./deployDev.hcl terragrunt apply
```