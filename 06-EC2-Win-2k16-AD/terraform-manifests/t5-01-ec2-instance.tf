#Create EC2 Instance and Deploy AWX
resource "aws_instance" "ec2_ad" {
  ami = "ami-0eaa5dc91b7f6a340"
  instance_type = var.instance_type
  user_data = file("${path.module}/config.ps1")
  key_name = var.instance_keypair
  vpc_security_group_ids = [ aws_security_group.sg-ad.id]
  tags = {
    "Name" = "WIN-AD" 
  }
}

