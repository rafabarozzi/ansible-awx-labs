#Create EC2 Instance and Deploy Zabbix
resource "aws_instance" "ec2_zabbix" {
  ami = "ami-053b0d53c279acc90"
  instance_type = var.instance_type_zabbix
  user_data = file("${path.module}/zabbix-jenkins.sh")
  key_name = var.instance_keypair
  vpc_security_group_ids = [ aws_security_group.sg-ssh.id, aws_security_group.sg-web.id ]
  tags = {
    "Name" = "Ubuntu22.04 - Zabbix / Jenkins" 
  }
}

