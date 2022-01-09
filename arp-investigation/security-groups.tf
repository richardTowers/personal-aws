data "http" "ip" {
  url = "https://ifconfig.me"
}

resource "aws_security_group" "allow_ssh" {
  vpc_id = aws_vpc.this.id

  ingress {
    cidr_blocks = ["${data.http.ip.body}/32"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
}

resource "aws_security_group" "allow_egress" {
  vpc_id = aws_vpc.this.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

resource "aws_security_group" "foo" {
  vpc_id = aws_vpc.this.id
}

resource "aws_security_group" "bar" {
  vpc_id = aws_vpc.this.id
}

resource "aws_security_group_rule" "bar_from_foo" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.bar.id
  source_security_group_id = aws_security_group.foo.id
}

resource "aws_security_group_rule" "foo_to_bar" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.foo.id
  source_security_group_id = aws_security_group.bar.id
}

