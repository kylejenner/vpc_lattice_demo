#Create network VPC this includes NAT for internet - Consumer1 and consumer2 VPCs will use this via TGW
resource "aws_vpc" "network-vpc" {
  provider             = aws.network
  cidr_block           = var.vpc-cidr-network
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.environment-network}-vpc"
  }
}
resource "aws_internet_gateway" "network-igw" {
  provider = aws.network
  vpc_id   = aws_vpc.network-vpc.id
  tags = {
    Name = "${var.environment-network}-igw"
  }
}
resource "aws_subnet" "network-subnet-pub" {
 count      = length(var.subnet-pub-network)
 vpc_id     = aws_vpc.network-vpc.id
 cidr_block = element(var.subnet-pub-network, count.index)
 availability_zone = element(var.azs, count.index)
 
 tags = {
   Name = "${var.environment-network}-subnet-pub-${count.index + 1}"
 }
}
resource "aws_subnet" "network-subnet-priv" {
 count      = length(var.subnet-priv-network)
 vpc_id     = aws_vpc.network-vpc.id
 cidr_block = element(var.subnet-priv-network, count.index)
 availability_zone = element(var.azs, count.index)
 
 tags = {
   Name = "${var.environment-network}-subnet-priv-${count.index + 1}"
 }
}
resource "aws_eip" "network-nat-eip" {
  vpc = true
}
resource "aws_nat_gateway" "network-natgw" {
  allocation_id = aws_eip.network-nat-eip.id
  subnet_id     = aws_subnet.network-subnet-pub[0].id
  tags = {
    Name = "${var.environment-network}-natgw"
  }
}
resource "aws_route_table" "network-rt-pub-1" {
  provider = aws.network
  vpc_id   = aws_vpc.network-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.network-igw.id
  }
  route {
    cidr_block     = "172.17.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.central-tgw.id
  }  
  route {
    cidr_block     = "172.18.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.central-tgw.id
  }  
  route {
    cidr_block     = "172.19.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.central-tgw.id
  }  
  tags = {
    Name = "${var.environment-network}-pub-rt"
  }
}
resource "aws_route_table" "network-rt-priv-1" {
  provider = aws.network
  vpc_id   = aws_vpc.network-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.network-natgw.id
  }
  route {
    cidr_block     = "172.17.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.central-tgw.id
  }  
  route {
    cidr_block     = "172.18.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.central-tgw.id
  }  
  tags = {
    Name = "${var.environment-network}-priv-rt-1"
  }
}
resource "aws_route_table_association" "network-public-subnet-asso" {
 count = length(var.subnet-pub-network)
 subnet_id      = element(aws_subnet.network-subnet-pub[*].id, count.index)
 route_table_id = aws_route_table.network-rt-pub-1.id
}
resource "aws_route_table_association" "network-private-subnet-asso" {
 count = length(var.subnet-priv-network)
 subnet_id      = element(aws_subnet.network-subnet-priv[*].id, count.index)
 route_table_id = aws_route_table.network-rt-priv-1.id
}