variable "project" {
  type        = string
  description = "Name prefix and ownership tag."
  default     = "platform-lab"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,30}$", var.project))
    error_message = "project must be 3–31 lowercase letters, digits or hyphens, starting with a letter."
  }
}

variable "environment" {
  type        = string
  description = "Environment tag."
  default     = "lab"
  validation {
    condition     = contains(["lab", "dev", "staging", "prod"], var.environment)
    error_message = "environment must be lab, dev, staging or prod."
  }
}

variable "aws_region" {
  type        = string
  description = "Region that contains both selected availability zones."
  default     = "us-east-1"
}

variable "availability_zones" {
  type        = list(string)
  description = "Two distinct availability zones in aws_region."
  default     = ["us-east-1a", "us-east-1b"]
  validation {
    condition     = length(var.availability_zones) == 2 && length(distinct(var.availability_zones)) == 2
    error_message = "Provide exactly two distinct availability zones."
  }
}

variable "vpc_cidr" {
  type        = string
  description = "IPv4 /16 VPC CIDR, from which the module derives four /24 subnets."
  default     = "10.42.0.0/16"
  validation {
    condition     = can(cidrsubnet(var.vpc_cidr, 8, 11)) && can(regex("/16$", var.vpc_cidr))
    error_message = "vpc_cidr must be a valid IPv4 /16 network."
  }
}
