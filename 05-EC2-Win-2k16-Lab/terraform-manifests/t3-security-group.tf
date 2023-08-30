#Create Security Group - SSH Traffic
resource "aws_security_group" "sg-rdp" {
  name        = "rdpsg"
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
    Name = "sg-rdp"
  }
}
