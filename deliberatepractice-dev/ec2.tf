resource "aws_instance" "ec2" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.this.id
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.ssh_and_https.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "${data.template_file.ssh_key.rendered}" > /home/ec2-user/.ssh/authorized_keys
              chown ec2-user:ec2-user /home/ec2-user/.ssh/authorized_keys
              chmod 600 /home/ec2-user/.ssh/authorized_keys
              EOF

  tags = {
    Name = "terraform-ec2-instance"
  }
}

# Fetch Amazon Linux AMI ID
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }
}