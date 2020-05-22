terraform {
  backend "s3" {
    # bucket         = var.state_bucket_name
    # key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

# variable "state_bucket_name" {
#     default = "terraform-state"
# }

# variable "state_lock_table" {
#     default = "terraform-locks"
# }

# variable "region" {
#     default = "us-east-1"
# }

provider "aws" {
    profile    = "default"
    region     = var.region
}

# module "InfraPatternBook" {
#     source = "./InfraPatternBook"
# }

# module "pat-ntier" {
#   source    = "./InfraPatternBook/aws/patterns/ntier/"
#   region    = var.region
#   stack_ref = "myapp"

#   tiers = {
#     frontEnd = {
#       os            = "ubuntu-xenial"
#       instance_type = "t2.micro"
#       listeners = {
#         public  = [80]
#         private = []
#       }
#     },
#     backEnd = {
#       os            = "ubuntu-xenial"
#       instance_type = "t2.micro"
#       listeners = {
#         public  = [80]
#         private = []
#       }
#     }
#   }
# }