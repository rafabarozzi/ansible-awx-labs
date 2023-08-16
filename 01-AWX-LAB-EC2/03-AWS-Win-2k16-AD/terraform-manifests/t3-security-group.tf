#Buscar dados do Security Group
data "aws_security_group" "sg-ssh" {
  tags = {
    Name = "sg-ssh" 
  }
}


