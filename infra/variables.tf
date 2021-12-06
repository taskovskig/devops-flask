variable "aws" {
  description = "AWS related settings"
  type        = any
}

variable "helm_release_status" {
  description = "Whether to install the helm release"
  type        = bool
  default     = false
}

variable "helm_release_name" {
  description = "Whether to install the helm release"
  type        = string
  default     = "flask-app"
}
