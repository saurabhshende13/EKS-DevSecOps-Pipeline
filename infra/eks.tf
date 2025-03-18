provider "aws" {
  region = var.aws_region
}

resource "aws_iam_role" "eksctl_role" {
  name = "eksctl_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_admin_policy" {
  role       = aws_iam_role.eksctl_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_instance" "bootstrap_server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.eksctl_profile.name
  vpc_security_group_ids = [var.security_group_id]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              
              # Install AWS CLI
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              sudo ./aws/install

              # Install kubectl
              curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.26.4/2023-05-11/bin/linux/amd64/kubectl
              chmod +x kubectl
              sudo mv kubectl /usr/local/bin/

              # Install eksctl
              curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" | tar xz -C /tmp
              sudo mv /tmp/eksctl /usr/local/bin/

              # Verify installations
              aws --version
              kubectl version --client
              eksctl version
              
              # Create EKS Cluster
              eksctl create cluster --name my-eks-cluster --region us-east-1 --node-type t2.medium --nodes 2
              EOF

              

  tags = {
    Name = "EKS-Bootstrap-Server"
  }
}

resource "aws_iam_instance_profile" "eksctl_profile" {
  name = "eksctl_profile"
  role = aws_iam_role.eksctl_role.name
}
