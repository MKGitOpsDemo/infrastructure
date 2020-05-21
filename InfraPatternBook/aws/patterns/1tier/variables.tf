variable "region" {
}

variable "label" {
  description = "A label to apply to resources associated with this pattern"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "os" {
  description = "The OS to launch with"
}
