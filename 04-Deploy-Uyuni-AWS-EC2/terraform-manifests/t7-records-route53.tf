data "aws_route53_zone" "selected" {
  name = "rbarozzi.com"
}

resource "aws_route53_record" "Uyuni" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "uyuni.rbarozzi.com"
  type    = "A"
  ttl     = "60"
  records = [aws_instance.ec2_uyuni.public_ip]
}

resource "aws_route53_record" "Zabbix" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "zabbix.rbarozzi.com"
  type    = "A"
  ttl     = "60"
  records = [aws_instance.ec2_zabbix.public_ip]
}

resource "aws_route53_record" "Jenkins" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "jenkins.rbarozzi.com"
  type    = "A"
  ttl     = "60"
  records = [aws_instance.ec2_zabbix.public_ip]
}


# resource "aws_route53_record" "Lab" {
#   zone_id = data.aws_route53_zone.selected.zone_id
#   name    = "lab.rbarozzi.com"
#   type    = "A"
#   ttl     = "60"
#   records = [aws_instance.ec2_lab.public_ip]
# }