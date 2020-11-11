/*
* Provides a data source for searching AMIs.  Given a name filter and an owner 
* key will return the most recent AMI within the current region. 
*/

data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.namefilter]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [var.owner]
}

