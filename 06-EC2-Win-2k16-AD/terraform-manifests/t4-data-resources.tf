#Data Security Groups

data "aws_security_group" "rdp_sg" {
  tags = {
    Name = "sg-rdp" 
  }
}

data "aws_security_group" "ssh_sg" {
  tags = {
    Name = "sg-ssh" 
  }
}