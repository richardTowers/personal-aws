data "http" "ip" {
  url = "https://ifconfig.me"
}

variable "allow_ssh" {
  description = "If true, allows the current IP of the machine applying terraform to connect to port 22 on instances"
}

resource "aws_security_group" "allow_ssh" {
  vpc_id      = aws_vpc.this.id
  name_prefix = "allow_ssh_"
  description = "Allow SSH"

  ingress {
    cidr_blocks = var.allow_ssh ? ["${data.http.ip.body}/32"] : []
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "allow_egress" {
  vpc_id      = aws_vpc.this.id
  name_prefix = "allow_egress_"
  description = "Allow Egress to the entire internet"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  lifecycle {
    create_before_destroy = true
  }
}
