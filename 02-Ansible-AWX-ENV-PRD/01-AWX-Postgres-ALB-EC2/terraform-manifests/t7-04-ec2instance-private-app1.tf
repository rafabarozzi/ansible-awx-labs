# AWS EC2 Instance Terraform Module
# EC2 Instances that will be created in VPC Private Subnets for App1
module "ec2_private" {
  depends_on = [ module.vpc ] 
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.17.0"

  name                   = "${var.environment}-awx"
  ami                    = "ami-08b6e3ac65326f664"
  instance_type          = var.instance_type
  key_name               = var.instance_keypair
  vpc_security_group_ids = [module.private_sg.this_security_group_id]
  subnet_ids = [
    module.vpc.private_subnets[0],
    module.vpc.private_subnets[1]
  ]  
  instance_count         = var.private_instance_count
  user_data = file("${path.module}/config.sh")
  tags = local.common_tags
}


