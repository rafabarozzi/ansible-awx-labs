# # Recupera o certificado ACM
# data "aws_acm_certificate" "issued" {
#   domain   = "*.rbarozzi.com"
#   statuses = ["ISSUED"]
# }

# # # Define o ouvinte HTTPS existente no ALB
# resource "aws_lb_listener" "https_listener" {
#   load_balancer_arn = data.aws_lb.alb.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"

#   default_action {
#     type = "fixed-response"
#     fixed_response {
#       content_type = "text/plain"
#       message_body = "Default response for other paths"
#       status_code  = "404"
#     }
#   }

#   certificate_arn = data.aws_acm_certificate.issued.arn  # Associa o certificado ao ouvinte HTTPS
# }

# # Define o grupo de destino
# resource "aws_lb_target_group" "zabbix" {
#   name_prefix = "zbx-"
#   port        = 80
#   protocol    = "HTTP"
#   vpc_id      = data.aws_vpc.vpc.id
# }

# # Define a regra de roteamento para o ouvinte HTTPS
# resource "aws_lb_listener_rule" "zabbix_rule" {
#   listener_arn = aws_lb_listener.https_listener.arn
#   priority     = 100

#   action {
#     type = "fixed-response"
#     fixed_response {
#       content_type = "text/plain"
#       message_body = "Fixed Static message - for Zabbix Context"
#       status_code  = "200"
#     }
#   }

#   condition {
#     host_header {
#       values = ["zabbix.rbarozzi.com"]
#     }

#     path_pattern {
#       values = ["/zabbix/*"]
#     }
#   }
# }

# # Anexa a nova regra ao ouvinte HTTPS existente
# resource "aws_lb_listener_rule" "zabbix_rule_attachment" {
#   listener_arn = aws_lb_listener.https_listener.arn
#   depends_on   = [aws_lb_listener_rule.zabbix_rule] # Garante que a regra seja criada antes de ser anexada

#   condition {
#     host_header {
#       values = ["zabbix.rbarozzi.com"]
#     }

#     path_pattern {
#       values = ["/zabbix/*"]
#     }
#   }

#   action {
#     type = "fixed-response"
#     fixed_response {
#       content_type = "text/plain"
#       message_body = "ALB Fixed Static message"
#       status_code  = "200"
#     }
#   }
# }

# # Anexa a instância ao grupo de destino
# resource "aws_lb_target_group_attachment" "zabbix_attachment" {
#   target_group_arn = aws_lb_target_group.zabbix.arn
#   target_id        = module.ec2_private_zabbix.id[0]
# }
