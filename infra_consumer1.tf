#Create consumer1 VPC - private subnets only with no direct internet path
resource "aws_vpc" "consumer1-vpc" {
  provider             = aws.consumer1
  cidr_block           = var.vpc-cidr-consumer1
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.environment-consumer1}-vpc"
  }
}
resource "aws_subnet" "consumer1-subnet-priv" {
 count      = length(var.subnet-priv-consumer1)
 vpc_id     = aws_vpc.consumer1-vpc.id
 cidr_block = element(var.subnet-priv-consumer1, count.index)
 availability_zone = element(var.azs, count.index)
 
 tags = {
   Name = "${var.environment-consumer1}-subnet-priv-${count.index + 1}"
 }
}
resource "aws_route_table" "consumer1-rt-priv-1" {
  provider = aws.consumer1
  vpc_id   = aws_vpc.consumer1-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.central-tgw.id
  }     
  tags = {
    Name = "${var.environment-consumer1}-priv-rt-1"
  }
}
resource "aws_route_table_association" "consumer1-private-subnet-asso" {
 count = length(var.subnet-priv-consumer1)
 subnet_id      = element(aws_subnet.consumer1-subnet-priv[*].id, count.index)
 route_table_id = aws_route_table.consumer1-rt-priv-1.id
}