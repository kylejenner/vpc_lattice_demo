#Create consumer3 VPC with no direct internet path
resource "aws_vpc" "consumer3-vpc" {
  provider             = aws.consumer3
  cidr_block           = var.vpc-cidr-consumer3
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.environment-consumer3}-vpc"
  }
}
resource "aws_subnet" "consumer3-subnet-priv" {
 count      = length(var.subnet-priv-consumer3)
 vpc_id     = aws_vpc.consumer3-vpc.id
 cidr_block = element(var.subnet-priv-consumer3, count.index)
 availability_zone = element(var.azs, count.index)
 
  tags = {
    "Name"                                      = "${var.environment-consumer3}-subnet-priv-${count.index + 1}"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}
resource "aws_route_table" "consumer3-rt-priv-1" {
  provider = aws.consumer3
  vpc_id   = aws_vpc.consumer3-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.central-tgw.id
  }   
  tags = {
    Name = "${var.environment-consumer3}-priv-rt-1"
  }
}
resource "aws_route_table_association" "consumer3-private-subnet-asso" {
 count = length(var.subnet-priv-consumer3)
 subnet_id      = element(aws_subnet.consumer3-subnet-priv[*].id, count.index)
 route_table_id = aws_route_table.consumer3-rt-priv-1.id
}