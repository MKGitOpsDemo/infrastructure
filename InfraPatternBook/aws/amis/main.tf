/*
* Allows a quick lookup to the latest AMI for a given OS and major version within the current region.
*/

# Ubuntu AMI list
module "ubuntu-xenial" {
  source     = "./amisearch"
  owner      = "099720109477"
  namefilter = "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"
}

module "ubuntu-disco" {
  source     = "./amisearch"
  owner      = "099720109477"
  namefilter = "ubuntu/images/hvm-ssd/ubuntu-disco-19.04-amd64-server-*"
}

module "ubuntu-bionic" {
  source     = "./amisearch"
  owner      = "099720109477"
  namefilter = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
}

# Windows AMI list
module "windows-2019" {
  source     = "./amisearch"
  owner      = "801119661308"
  namefilter = "Windows_Server-2019-English-Full-Base-*"
}

module "windows-2016" {
  source     = "./amisearch"
  owner      = "801119661308"
  namefilter = "Windows_Server-2016-English-Full-Base-*"
}

module "windows-2012-r2" {
  source     = "./amisearch"
  owner      = "801119661308"
  namefilter = "Windows_Server-2012-R2_RTM-English-64Bit-Base-*"
}

# RHEL AMI list
module "rhel-6" {
  source     = "./amisearch"
  owner      = "309956199498"
  namefilter = "RHEL-6.??_HVM-2*x86*"
}

module "rhel-7" {
  source     = "./amisearch"
  owner      = "309956199498"
  namefilter = "RHEL-7.??_HVM-2*x86*"
}

module "rhel-8" {
  source     = "./amisearch"
  owner      = "309956199498"
  namefilter = "RHEL-8.??_HVM-2*x86*"
}

# Consolidated list of all referenceable AMIs
locals {
  amimap = {
    # Ubuntu
    ubuntu-xenial = "${module.ubuntu-xenial.image_id}",
    ubuntu-disco  = "${module.ubuntu-disco.image_id}",
    ubuntu-bionic = "${module.ubuntu-bionic.image_id}",

    # Windows
    windows-2019    = "${module.windows-2019.image_id}",
    windows-2016    = "${module.windows-2016.image_id}",
    windows-2012-r2 = "${module.windows-2012-r2.image_id}",

    # RHEL
    rhel-6 = "${module.rhel-6.image_id}",
    rhel-7 = "${module.rhel-7.image_id}",
    rhel-8 = "${module.rhel-8.image_id}",
  }
}

# Validation rules
locals {
  # Ensure input OS is in the explicit AMI map
  valid_amimaps = keys(local.amimap)
  validate_env  = index(local.valid_amimaps, var.os)
}

