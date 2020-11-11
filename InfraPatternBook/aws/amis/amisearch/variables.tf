variable "namefilter" {
  type        = string
  description = "AMI Name Filter, e.g. ubuntu-bionic-18.04-amd64-server-*"
}

variable "owner" {
  type        = string
  description = "AMI Owner ID, e.g. "
}
