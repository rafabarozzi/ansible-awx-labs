resource "aws_route53_zone" "private_zone" {
  name          = "rbarozzi.com."
  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

# Crie registros na zona DNS privada
resource "aws_route53_record" "awx_server" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "awx-server.rbarozzi.com"
  type    = "A"
  ttl     = 60
  records = [module.ec2_private.private_ip[0]]
}

resource "aws_route53_record" "pgsql" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "pgsql.rbarozzi.com"
  type    = "A"
  ttl     = 60
  records = [module.ec2_private_postgres.private_ip[0]]
}
