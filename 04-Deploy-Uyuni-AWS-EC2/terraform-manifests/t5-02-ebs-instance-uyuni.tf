#Create EBS Volume for Uyuni 
resource "aws_ebs_volume" "st1" {
    availability_zone = aws_instance.ec2_uyuni.availability_zone
    size = 250
    tags = {
        name = "uyunilv"
    }
}

#Attach EBS Volume to EC2 Instance
resource "aws_volume_attachment" "ebs" {
    device_name = "/dev/sdb"
    volume_id = aws_ebs_volume.st1.id
    instance_id = aws_instance.ec2_uyuni.id
}
