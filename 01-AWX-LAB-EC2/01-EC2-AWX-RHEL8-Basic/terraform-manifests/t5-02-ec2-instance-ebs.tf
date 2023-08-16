#Create EBS Volume for AWX use 
resource "aws_ebs_volume" "st1" {
    availability_zone = aws_instance.ec2_awx.availability_zone
    size = 80
    tags = {
        name = "awxvl"
    }
}

#Attach EBS Volume to EC2 Instance
resource "aws_volume_attachment" "ebs" {
    device_name = "/dev/sdb"
    volume_id = aws_ebs_volume.st1.id
    instance_id = aws_instance.ec2_awx.id
}
