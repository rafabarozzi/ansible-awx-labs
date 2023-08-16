#Create EC2 Instance for Lab
resource "aws_instance" "ec2_lab" {
  ami = "ami-08b6e3ac65326f664"
  instance_type = var.instance_type_lab
  user_data = file("${path.module}/rhel.sh")
  key_name = var.instance_keypair
  vpc_security_group_ids = [ aws_security_group.sg-ssh.id]
  tags = {
    "Name" = "RHEL 8 - Lab" 
  }
}
