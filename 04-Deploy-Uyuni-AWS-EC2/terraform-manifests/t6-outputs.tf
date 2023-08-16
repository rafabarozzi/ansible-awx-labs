#Terraform Output Values

#EC2 Instance Public IP - Uyuni

output "instance_publicip_uyuni" {
  description = "EC2 Instance Public IP"
  value = aws_instance.ec2_uyuni.public_ip
}

#EC2 Instance Public DNS
output "instance_publicdns_uyuni" {
  description = "EC2 Instance Public DNS"
  value = aws_instance.ec2_uyuni.public_dns
}


#EC2 Instance Public IP - Zabbix

output "instance_publicip_zabbix" {
  description = "EC2 Instance Public IP"
  value = aws_instance.ec2_zabbix.public_ip
}

#EC2 Instance Public DNS
output "instance_publicdns_zabbix" {
  description = "EC2 Instance Public DNS"
  value = aws_instance.ec2_zabbix.public_dns
}



#EC2 Instance Public IP - Lab

output "instance_publicip_lab" {
  description = "EC2 Instance Public IP"
  value = aws_instance.ec2_lab.public_ip
}

#EC2 Instance Public DNS
output "instance_publicdns_lab" {
  description = "EC2 Instance Public DNS"
  value = aws_instance.ec2_lab.public_dns
}



# output "rds_endpoint" {
#   description = "RDS Endpoint"
#   value = aws_db_instance.uyuni.endpoint
# }