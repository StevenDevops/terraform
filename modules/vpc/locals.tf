locals {
  public_subnets = {
    for az, subnets in var.subnets :
    az => subnets["public"]
  }

  private_subnets = {
    for az, subnets in var.subnets :
    az => subnets["private"]
  }

  bucket_name = "s3-flow-logs-bucket-${random_pet.this.id}"

  tags = {
    "Terraform"   = true
    "Environment" = terraform.workspace
  }
}