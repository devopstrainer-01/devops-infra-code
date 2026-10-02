variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-north-1"
}

variable "vpc_name" {
  description = "Name tag applied to the VPC and derived resources"
  type        = string
  default     = "devops-bishnu-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "availability_zone" {
  description = "Availability zone for the public subnet"
  type        = string
  default     = "eu-north-1a"
}

variable "instance_name" {
  description = "Name tag applied to the EC2 instance and its security group"
  type        = string
  default     = "bishnu-web-server"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance. Default is Ubuntu 24.04 LTS (eu-north-1, login user: ubuntu) to match userdata.sh, which uses apt/apache2"
  type        = string
  default     = "ami-0769f265f707fecc8"
}

variable "workloads" {
  description = "EC2 instances to provision, keyed by role. Each gets its own security group and user-data script, in the same public subnet"
  type = map(object({
    instance_type = string
    user_data     = string
    ingress = list(object({
      port        = number
      cidr_blocks = list(string)
    }))
  }))
  default = {
    web = {
      instance_type = "t3.micro"
      user_data     = "userdata/web.sh"
      ingress = [
        { port = 80, cidr_blocks = ["0.0.0.0/0"] }
      ]
    }
    cicd = {
      instance_type = "t3.medium"
      user_data     = "userdata/jenkins.sh"
      ingress = [
        { port = 8080, cidr_blocks = ["0.0.0.0/0"] }
      ]
    }
    db = {
      instance_type = "t3.micro"
      user_data     = "userdata/db.sh"
      ingress       = [
        { port = 5432, cidr_blocks =["0.0.0.0/0"] }
      ]
    }
  }
}

variable "key_name" {
  description = "SSH key pair name. If manage_key_pair is true, Terraform creates it when missing and warns when it already exists"
  type        = string
  default     = "new-devops-bishnu"
}

variable "manage_key_pair" {
  description = "Let Terraform check for and create the EC2 key pair named var.key_name. Set to false if you manage the key pair yourself outside Terraform"
  type        = bool
  default     = true
}

variable "allowed_ssh_cidr" {
  description = "CIDR blocks allowed to reach the instance over SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Extra tags merged into every resource"
  type        = map(string)
  default     = {}
}
