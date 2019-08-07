# terraform-lambdas-api-gateway-cloudfront

Example terraform/terragrunt scripts for lambdas, api-gateway and cloudfront

## Intro

This is a working set of Terraform files that will deploy a few resources:

* Stores terraform state remotely in an S3 bucket
* S3 buckets - public & private in eu-west-2, lambda_edge in us-east-1 region
* S3 bucket objects - image and zipped lambda files
* Standard lambda (created from zipped source in private bucket)
* API gateway to access the normal lambda
* Edge lambda (created from zipped source in lambda edge bucket)
* Cloudfront distribution with public bucket as origin and edge lambda association
* Various IAM roles, policies and permissions to make the bits work together

## Install 

### Install Terraform & terragrunt

```
brew install terraform terragrunt
```

### Install AWS CLI

Instructions here <https://docs.aws.amazon.com/cli/latest/userguide/install-macos.html>



## Write a Terragrunt file

Save the below to `deployDev.hcl` at the root of the project

* Replace `NAME_OF_BUCKET_FOR_STORING_STATE` with a pre-created S3 bucket name in the region, terraform will use this to remotely store your terraform state in, just create it through the AWS UI.
* Change `YOUR_ACCOUNT_ID` to your own account id.
* If you have AWS environment variables set it will override the role config, this can cause issues if they are not the same as the profile you have set in this file.
* If you have multiple profiles or your default profiled isn't called 'default' you'll need to change the `profile` key as well

```tf
remote_state {
  backend = "s3"
  config = {
    profile = "personal"
    region  = "eu-west-2"
    bucket  = "NAME_OF_BUCKET_FOR_STORING_STATE" # need to create this outside terraform
    key     = "my-project-terraformstate"
  }
}


inputs = {
  profile                 = "personal"
  public_bucket_name      = "my-project-public-bucket"
  private_bucket_name     = "my-project-private-bucket"
  lambda_edge_bucket_name = "my-project-lambda-edge-bucket"
  region                  = "eu-west-2"
  lambda_edge_region      = "us-east-1"
  account_id              = "YOUR_ACCOUNT_ID"
  project_prefix          = "my-project"
}
```

## Run Deployment

Run the deployment via terragrunt

```
TERRAGRUNT_CONFIG=./deployDev.hcl terragrunt apply
```