# PostgreSQL EC2 Instance Terraform Module
# EC2 Instances that will be created in VPC Private Subnets for PostgreSQL
module "ec2_private_zabbix" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.17.0"

  name                   = "${var.environment}-zabbix"
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = var.instance_type
  key_name               = var.instance_keypair
  vpc_security_group_ids = [data.aws_security_group.private_sg.id]
  subnet_ids = [
    local.subnet_ids_list[0],
    local.subnet_ids_list[1]
  ]  
  instance_count         = var.private_instance_count
  user_data = file("${path.module}/zabbix.sh")
  tags = local.common_tags
}
