### Network VPC variables
variable "environment-network" {
  type    = string
  default = "network"
}
variable "azs" {
 type        = list(string)
 description = "Availability Zones"
 default     = ["us-west-2a", "us-west-2b"]
}
variable "subnet-pub-network" {
 type        = list(string)
 description = "Public Subnet CIDR values for Network VPC"
 default     = ["172.16.1.0/24", "172.16.2.0/24"]
}
variable "subnet-priv-network" {
 type        = list(string)
 description = "Private Subnet CIDR values for network VPC"
 default     = ["172.16.3.0/24", "172.16.4.0/24"]
}
variable "vpc-cidr-network" {
  type    = string
  default = "172.16.0.0/16"
}

### Consumer1 VPC variables
variable "environment-consumer1" {
  type    = string
  default = "consumer1"
}
variable "subnet-pub-consumer1" {
 type        = list(string)
 description = "Public Subnet CIDR values for consumer1 VPC"
 default     = ["172.17.1.0/24", "172.17.2.0/24"]
}
variable "subnet-priv-consumer1" {
 type        = list(string)
 description = "Private Subnet CIDR values for consumer1 VPC"
 default     = ["172.17.3.0/24", "172.17.4.0/24"]
}
variable "vpc-cidr-consumer1" {
  type    = string
  default = "172.17.0.0/16"
}

### consumer2 VPC variables
variable "environment-consumer2" {
  type    = string
  default = "consumer2"
}
variable "subnet-pub-consumer2" {
 type        = list(string)
 description = "Public Subnet CIDR values for consumer2 VPC"
 default     = ["172.18.1.0/24", "172.18.2.0/24"]
}
variable "subnet-priv-consumer2" {
 type        = list(string)
 description = "Private Subnet CIDR values for consumer2 VPC"
 default     = ["172.18.3.0/24", "172.18.4.0/24"]
}
variable "vpc-cidr-consumer2" {
  type    = string
  default = "172.18.0.0/16"
}

### consumer3 VPC variables
variable "environment-consumer3" {
  type    = string
  default = "consumer3"
}
variable "subnet-pub-consumer3" {
 type        = list(string)
 description = "Public Subnet CIDR values for consumer3 VPC"
 default     = ["172.19.1.0/24", "172.19.2.0/24"]
}
variable "subnet-priv-consumer3" {
 type        = list(string)
 description = "Private Subnet CIDR values for consumer3 VPC"
 default     = ["172.19.3.0/24", "172.19.4.0/24"]
}
variable "vpc-cidr-consumer3" {
  type    = string
  default = "172.19.0.0/16"
}
variable "cluster_name" {
  default = "consumer3-eks-cluster"
}
variable "cluster_version" {
  default = "1.27"
}

### EC2 variables

variable "message" {
  type        = string
  default = "Webpage running on Consumer1 EC2 instance"
}