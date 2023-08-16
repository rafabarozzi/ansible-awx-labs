#Recuperar Dados do SG
data "aws_security_group" "private_sg" {
  tags = {
    Name = "private-sg" 
  }
}

data "aws_security_group" "loadbalancer_sg" {
  tags = {
    Name = "loadbalancer_sg" 
  }
}

#Recuperar Dados da VPC
data "aws_vpc" "vpc" {
  tags = {
    Name = "lab-dev-awxvpc"  
  }
}

#Recuperar Dados das Subnets
data "aws_subnet_ids" "subnets" {
  vpc_id = data.aws_vpc.vpc.id
}


# Converter o conjunto de IDs de subnets em uma lista
locals {
  subnet_ids_list = tolist(data.aws_subnet_ids.subnets.ids)
}

# # Escolher uma subnet para a instância EC2
# locals {
#   selected_subnet_id = local.subnet_ids_list[0]  # Escolha o índice da subnet desejada
# }


#Recuperar Dados da Private Zone
data "aws_route53_zone" "private_zone" {
  name          = "rbarozzi.com"
}

# Get DNS information from AWS Route53
data "aws_route53_zone" "mydomain" {
  name         = "rbarozzi.com"
}

# Output MyDomain Zone ID
output "mydomain_zoneid" {
  description = "The Hosted Zone id of the desired Hosted Zone"
  value = data.aws_route53_zone.mydomain.zone_id 
}

# Output MyDomain name
output "mydomain_name" {
  description = " The Hosted Zone name of the desired Hosted Zone."
  value = data.aws_route53_zone.mydomain.name
}

# #Recuperar Dados do ALB
# data "aws_lb" "alb" {
#   name = "lab-dev-alb"  
# }

 