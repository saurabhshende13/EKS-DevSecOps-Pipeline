resource "aws_instance" "sonarqube_server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.sonarqube.id]
  subnet_id = aws_subnet.main.id
#   user_data              = file("userdata/sonarqube.sh")
  user_data = <<EOF
#!/bin/bash
sudo apt update -y
sudo apt install docker.io -y
sudo docker run -itd --name sonarqube -p 9000:9000 sonarqube:lts
EOF

  tags = {
    Name = "SonarQube Server"
  }
}