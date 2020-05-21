variable "region" {
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

# variable "os" {
#   description = "The OS to launch with"
# }

variable "tiers" {
  description = "Specifications for each tier"
  type        = map
}

variable "git_user" {
  description = "Username to use to access the SCM repo"
  default     = "devops-read-config-at-992565782035"
}

variable "git_pass" {
  description = "Password to use to access the SCM repo"
  default     = "Gf4qsps0uiCLDBQaIejQXbEPK8rMSAPHREi+yTtcWSw="
}

variable "git_url" {
  description = "URL for SCM repo"
  default     = "git-codecommit.us-east-1.amazonaws.com/v1/repos/Runbooks"
}

variable "stack_ref" {
  description = "reference for this stack group"
}

