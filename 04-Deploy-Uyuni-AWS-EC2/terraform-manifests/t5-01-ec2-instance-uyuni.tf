#Create EC2 Instance and Deploy Uyuni
resource "aws_instance" "ec2_uyuni" {
  ami = "ami-06b6eb8f8fb7f2916"
  instance_type = var.instance_type
  user_data = file("${path.module}/uyuni.sh")
  key_name = var.instance_keypair
  vpc_security_group_ids = [ aws_security_group.sg-ssh.id, aws_security_group.sg-web.id ]
  tags = {
    "Name" = "OpenSuse15.4 - Uyuni" 
  }
}

