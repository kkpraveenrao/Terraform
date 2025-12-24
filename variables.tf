# variables.tf
variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
}

variable "EC2_AMI" {
  description = "The AMI for the EC2"
  type        = string
}

variable "EC2_type" {
  description = "The instance type for the EC2"
  type        = string
}

variable "EC2_key" {
  description = "The Key for the EC2"
  type        = string
}


variable "EC2_tags" {
  description = "Tags for the EC2"
  type        = map(string)
}

variable "EC2_SecurityGroupIDs" {
  description = "Security Groups for the EC2"
  type        = list(string)
}

variable "EC2_Role" {
  description = "Iam Role for the EC2"
  type        = string
}
