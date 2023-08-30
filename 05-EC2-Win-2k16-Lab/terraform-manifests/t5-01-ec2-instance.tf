#Create EC2 Instance and Deploy AWX
resource "aws_instance" "ec2_win" {
  ami = "ami-0eaa5dc91b7f6a340"
  instance_type = var.instance_type
  #user_data = file("${path.module}/config.sh")
  key_name = var.instance_keypair
  vpc_security_group_ids = [ aws_security_group.sg-rdp.id]
  tags = {
    "Name" = "WIN-2K16" 
  }
}

