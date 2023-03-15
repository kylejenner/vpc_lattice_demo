### EC2 Instance launching local app
resource "aws_instance" "consumer2-ec2-web" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.consumer2-subnet-priv[0].id
  vpc_security_group_ids = [aws_security_group.consumer2-ec2-web-sg.id]
  iam_instance_profile =  aws_iam_instance_profile.web-ec2-instance-profile.name
  user_data       = "${file("template/user_data_consumer2.sh")}"

  tags = {
   Name = "${var.environment-consumer2}-ec2-web"
  }
}