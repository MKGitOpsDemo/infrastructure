# resource "aws_instance" "basic_svr" {
#   ami           = "ami-0b69ea66ff7391e80"
#   instance_type = "t2.micro"
# }

variable "region" {
  default = "us-east-1"
}

provider "aws" {
  region = var.region
}

# module "pat-1tier-disco" {
#   source = "./aws/patterns/1tier/"
#   region = "${var.region}"
#   os     = "windows-2019"
# }

# module "pat-1tier-xenial" {
#   source = "./aws/patterns/1tier/"
#   region = "${var.region}"
#   os     = "windows-2016"
# }

# module "pat-1tier-win2012" {
#   source = "./aws/patterns/1tier/"
#   region = "${var.region}"
#   os     = "windows-2012-r2"
# }


# module "aws_ami" {
#   source = "./aws/amis/"
# }

# resource "aws_instance" "web" {
#   ami           = "${module.aws_ami.ubuntu.id}"
#   instance_type = "t2.micro"

#   tags {
#     Name = "HelloUbuntu"
#   }
# }

# data "aws_ami" "ubuntu" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["099720109477"] # Canonical
# }

# output "image_id" {
#   value = "${module.aws_ami.ubuntu.id}"
# }

# resource "aws_instance" "web" {
#   # ami           = "${data.aws_ami.ubuntu.id}"
#   ami           = "${module.aws_ami.image_id}"
#   instance_type = "t2.micro"
# }


# module "pat-ntier" {
#   source = "./aws/patterns/ntier/"
#   region = "${var.region}"
#   # os     = "windows-2012-r2"

#   tiers = {
#     front-end = {
#       os            = "ubuntu-xenial",
#       instance_type = "t2.micro",
#       listeners = {
#         public  = [80, 443],
#         private = [1024, 5555]
#       }
#     },

#     back-end = {
#       os            = "ubuntu-disco",
#       instance_type = "t2.micro",
#       listeners = {
#         public  = [3389, 1433],
#         private = [6454, 8888]
#     } },
#   }
# }

# module "amisearch" {
#   source = "./aws/amis/"
# }

# output "amis" {
#   value = "${module.amisearch.image_ids}"
# }

# module "pat-ntier" {
#   source    = "./aws/patterns/ntier/"
#   region    = "${var.region}"
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

# module "eks" {
#   source = "./aws/patterns/eks"
#   region = "${var.region}"
# }

# provider "kubernetes" {
#   config_path = "${module.eks.kubectl_config_filename}"
# }

# module "simplekubapp" {
#   source = "./kubernetes/simple"
# }

# output "simpleappaddress" {
#   value = module.simplekubapp.access_addr
# }

# module "kubdash" {
#   source = "./kubernetes/dashboard"
# }

# output "dashboardaddress" {
#   value = module.kubdash.access_addr
# }

# resource 
