variable "branch" {}

variable "nodes" {
    default = 3
}

locals {
  name = var.branch
}
