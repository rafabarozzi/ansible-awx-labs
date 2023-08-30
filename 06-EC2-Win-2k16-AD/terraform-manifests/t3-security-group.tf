#Create Security Group - SSH Traffic
resource "aws_security_group" "sg-ad" {
  name        = "adsg"
  description = "Security Group to allow inbound RDP"

  ingress {
    description      = "Allow Port 3389"
    from_port        = 3389
    to_port          = 3389
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  egress {
    description = "Allow all IPs and ports outbound"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "sg-ad"
  }
}

# Adicionar regra de entrada para permitir tráfego do Security Group "sg-ssh"
resource "aws_security_group_rule" "allow_from_sg_ssh" {
  type        = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"
  source_security_group_id = data.aws_security_group.ssh_sg.id
  security_group_id       = aws_security_group.sg-ad.id
}

# Adicionar regra de entrada para permitir tráfego do Security Group "sg-rdp"
resource "aws_security_group_rule" "allow_from_sg_rdp" {
  type        = "ingress"
  from_port   = 0
  to_port     = 65535  #
  protocol    = "tcp"
  source_security_group_id = data.aws_security_group.rdp_sg.id
  security_group_id       = aws_security_group.sg-ad.id
}

