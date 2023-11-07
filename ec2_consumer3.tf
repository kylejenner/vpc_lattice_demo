### EC2 Instance launching local app
resource "aws_instance" "consumer3-ec2-web" {
  ami             = data.aws_ami.ami.id
  instance_type   = "t3.micro"
  subnet_id       = aws_subnet.consumer3-subnet-priv[0].id
  vpc_security_group_ids = [aws_security_group.consumer3-ec2-web-sg.id]
  iam_instance_profile =  aws_iam_instance_profile.web-ec2-instance-profile.name
  user_data       = "${file("template/user_data_consumer3.sh")}"
  depends_on      = [aws_nat_gateway.network-natgw]

  tags = {
   Name = "${var.environment-consumer3}-ec2-web"
  }
}