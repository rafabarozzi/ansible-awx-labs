# DNS Registration 
resource "aws_route53_record" "apps_dns" {
  zone_id = data.aws_route53_zone.mydomain.zone_id 
  name    = "awx.rbarozzi.com"
  type    = "A"
  alias {
    name                   = module.alb.this_lb_dns_name
    zone_id                = module.alb.this_lb_zone_id
    evaluate_target_health = true
  }  
}

resource "aws_route53_record" "bastion" {
  zone_id = data.aws_route53_zone.mydomain.zone_id 
  name    = "bastion.rbarozzi.com"
  type    = "A"
  ttl     = "60"
  records = [module.ec2_public.public_ip[0]]
}
