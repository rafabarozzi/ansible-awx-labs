data "aws_route53_zone" "selected" {
  name = "rbarozzi.com"
}

resource "aws_route53_record" "AWX" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "awx.rbarozzi.com"
  type    = "A"
  ttl     = "60"
  records = [aws_instance.ec2_awx.public_ip]
}