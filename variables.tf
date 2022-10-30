variable "external_ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "instance-type" {
  type    = string
  default = "t3.micro"
}

variable "environment" {
  description = "Environment Variable used as a prefix"
  default     = "dev"
}