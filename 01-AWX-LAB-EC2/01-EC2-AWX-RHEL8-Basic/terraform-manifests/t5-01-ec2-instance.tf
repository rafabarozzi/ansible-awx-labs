#Create EC2 Instance and Deploy AWX
resource "aws_instance" "ec2_awx" {
  ami = "ami-08b6e3ac65326f664"
  instance_type = var.instance_type
  user_data = file("${path.module}/config.sh")
  key_name = var.instance_keypair
  vpc_security_group_ids = [ aws_security_group.sg-ssh.id, aws_security_group.sg-web.id ]
  tags = {
    "Name" = "RHEL8 - AWX" 
  }
}

