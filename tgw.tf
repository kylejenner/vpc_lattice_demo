###Create Central TGW
resource "aws_ec2_transit_gateway" "central-tgw" {
  description = "Transit Gateway for inter vpc connection"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support = "enable"
  tags = {Name = "central-tgw"}
}

####Create TGW attachements
resource "aws_ec2_transit_gateway_vpc_attachment" "network-vpc-att" {
  subnet_ids         = "${aws_subnet.network-subnet-priv.*.id}"
  transit_gateway_id = aws_ec2_transit_gateway.central-tgw.id
  vpc_id             = aws_vpc.network-vpc.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {Name = "${var.environment-network}-vpc-att"}
}
resource "aws_ec2_transit_gateway_vpc_attachment" "consumer1-vpc-att" {
  subnet_ids         = "${aws_subnet.consumer1-subnet-priv.*.id}"
  transit_gateway_id = aws_ec2_transit_gateway.central-tgw.id
  vpc_id             = aws_vpc.consumer1-vpc.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {Name = "${var.environment-consumer1}-vpc-att"}
}
resource "aws_ec2_transit_gateway_vpc_attachment" "consumer2-vpc-att" {
  subnet_ids         = "${aws_subnet.consumer2-subnet-priv.*.id}"
  transit_gateway_id = aws_ec2_transit_gateway.central-tgw.id
  vpc_id             = aws_vpc.consumer2-vpc.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {Name = "${var.environment-consumer2}-vpc-att"}
}
resource "aws_ec2_transit_gateway_vpc_attachment" "consumer3-vpc-att" {
  subnet_ids         = "${aws_subnet.consumer3-subnet-priv.*.id}"
  transit_gateway_id = aws_ec2_transit_gateway.central-tgw.id
  vpc_id             = aws_vpc.consumer3-vpc.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {Name = "${var.environment-consumer3}-vpc-att"}
}

####Create TGW route table
resource "aws_ec2_transit_gateway_route_table" "network-tgw-rt" {
  transit_gateway_id = aws_ec2_transit_gateway.central-tgw.id
  tags = {Name = "${var.environment-network}-tgw-att-rt"}
}
resource "aws_ec2_transit_gateway_route_table" "consumer1-tgw-rt" {
  transit_gateway_id = aws_ec2_transit_gateway.central-tgw.id
  tags = {Name = "${var.environment-consumer1}-tgw-att-rt"}
}
resource "aws_ec2_transit_gateway_route_table" "consumer2-tgw-rt" {
  transit_gateway_id = aws_ec2_transit_gateway.central-tgw.id
  tags = {Name = "${var.environment-consumer2}-tgw-att-rt"}
}
resource "aws_ec2_transit_gateway_route_table" "consumer3-tgw-rt" {
  transit_gateway_id = aws_ec2_transit_gateway.central-tgw.id
  tags = {Name = "${var.environment-consumer3}-tgw-att-rt"}
}

####Create TGW static route
resource "aws_ec2_transit_gateway_route" "network-tgw-route" {
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.network-vpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.network-tgw-rt.id
  }
resource "aws_ec2_transit_gateway_route" "consumer1-tgw-route" {
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.network-vpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.consumer1-tgw-rt.id
  }
resource "aws_ec2_transit_gateway_route" "consumer1-tgw-route-a" {
  destination_cidr_block = "172.18.0.0/16"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.consumer1-tgw-rt.id
  blackhole = true
  }
resource "aws_ec2_transit_gateway_route" "consumer1-tgw-route-b" {
  destination_cidr_block = "172.19.0.0/16"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.consumer1-tgw-rt.id
  blackhole = true
  }
resource "aws_ec2_transit_gateway_route" "consumer2-tgw-route" {
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.network-vpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.consumer2-tgw-rt.id
  }
resource "aws_ec2_transit_gateway_route" "consumer2-tgw-route-a" {
  destination_cidr_block = "172.17.0.0/16"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.consumer2-tgw-rt.id
  blackhole = true
  }
resource "aws_ec2_transit_gateway_route" "consumer2-tgw-route-b" {
  destination_cidr_block = "172.19.0.0/16"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.consumer2-tgw-rt.id
  blackhole = true
  }
resource "aws_ec2_transit_gateway_route" "consumer3-tgw-route" {
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.network-vpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.consumer3-tgw-rt.id
  }
resource "aws_ec2_transit_gateway_route" "consumer3-tgw-route-a" {
  destination_cidr_block = "172.17.0.0/16"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.consumer3-tgw-rt.id
  blackhole = true
  }
resource "aws_ec2_transit_gateway_route" "consumer3-tgw-route-b" {
  destination_cidr_block = "172.18.0.0/16"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.consumer3-tgw-rt.id
  blackhole = true
  }

####Create TGW route table association
resource "aws_ec2_transit_gateway_route_table_association" "central-tgw-assoc-network-network" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.network-vpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.network-tgw-rt.id
}
resource "aws_ec2_transit_gateway_route_table_association" "central-tgw-assoc-network-consumer1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.consumer1-vpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.consumer1-tgw-rt.id
}
resource "aws_ec2_transit_gateway_route_table_association" "central-tgw-assoc-network-consumer2" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.consumer2-vpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.consumer2-tgw-rt.id
}
resource "aws_ec2_transit_gateway_route_table_association" "central-tgw-assoc-network-consumer3" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.consumer3-vpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.consumer3-tgw-rt.id
}

####Create TGW route table propagation
resource "aws_ec2_transit_gateway_route_table_propagation" "central-tgw-prop-network-a" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.network-vpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.network-tgw-rt.id
}
resource "aws_ec2_transit_gateway_route_table_propagation" "central-tgw-prop-network-b" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.consumer1-vpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.network-tgw-rt.id
}
resource "aws_ec2_transit_gateway_route_table_propagation" "central-tgw-prop-network-c" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.consumer2-vpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.network-tgw-rt.id
}
resource "aws_ec2_transit_gateway_route_table_propagation" "central-tgw-prop-network-d" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.consumer3-vpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.network-tgw-rt.id
}
resource "aws_ec2_transit_gateway_route_table_propagation" "central-tgw-prop-consumer1-a" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.network-vpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.consumer1-tgw-rt.id
}
resource "aws_ec2_transit_gateway_route_table_propagation" "central-tgw-prop-consumer1-b" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.consumer1-vpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.consumer1-tgw-rt.id
}
resource "aws_ec2_transit_gateway_route_table_propagation" "central-tgw-prop-consumer2-a" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.network-vpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.consumer2-tgw-rt.id
}
resource "aws_ec2_transit_gateway_route_table_propagation" "central-tgw-prop-consumer2-b" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.consumer2-vpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.consumer2-tgw-rt.id
}
resource "aws_ec2_transit_gateway_route_table_propagation" "central-tgw-prop-consumer3-a" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.network-vpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.consumer3-tgw-rt.id
}
resource "aws_ec2_transit_gateway_route_table_propagation" "central-tgw-prop-consumer3-b" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.consumer3-vpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.consumer3-tgw-rt.id
}