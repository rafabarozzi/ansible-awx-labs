# #Get lastet AMI ID for Amazon Linux

# data "aws_ami" "amzlinux2" {
# #   executable_users = ["self"]
#   most_recent      = true
# #   name_regex       = "^myami-\\d{3}"
#   owners           = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["al2023-ami-2023.*-kernel-6.1-*"]
#   }

#   filter {
#     name   = "root-device-type"
#     values = ["ebs"]
#   }

# #   filter {
# #     name   = "virtualization-type"
# #     values = ["hvm"]
# #   }



#     filter {
#     name   = "architecture"
#     values = ["x86_64"]
#   }
# }