# EC2 Instance for Jenkins Master
resource "aws_instance" "jenkins_master" {
  ami                    = "ami-0c7217cdde317cfec"  # Ubuntu 22.04 LTS in us-east-1
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.jenkins_master.id]
  key_name               = "east1kp"

  associate_public_ip_address = true  # ✅ This enables SSH from outside

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "jenkins-master"
  }
}
