provider "aws" {
  region = var.aws_region
}

# Get caller identity for tagging or referencing
data "aws_caller_identity" "current" {}

# Create a KMS key for EBS encryption
resource "aws_kms_key" "ebs_key" {
  description             = "KMS key for EBS encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

# Generate TLS key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create EC2 key pair using public key
resource "aws_key_pair" "generated_key" {
  key_name   = "smallcase-instance"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Save PEM key locally
resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/smallcase-instance.pem"
  file_permission = "0600"
}

# Create security group
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP for Docker app"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Fetching dynamic Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Launch EC2 instance
resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "m5.large"
  associate_public_ip_address = true
  key_name               = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]
  user_data              = file("ec2-user-data.sh")

  root_block_device {
    volume_size = 10
    encrypted   = true
    kms_key_id  = aws_kms_key.ebs_key.arn
  }

  tags = {
    Name = "smallcase-instance"
  }
}

# Output EC2 public IP of the instance
output "instance_public_ip" {
  value = aws_instance.web.public_ip
}
