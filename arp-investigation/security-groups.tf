data "http" "ip" {
  url = "https://ifconfig.me"
}

resource "aws_security_group" "allow_ssh" {
  vpc_id      = aws_vpc.this.id
  name_prefix = "allow_ssh_"
  description = "Allow SSH"

  ingress {
    cidr_blocks = ["${data.http.ip.body}/32"]
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

resource "aws_security_group" "client" {
  vpc_id      = aws_vpc.this.id
  name_prefix = "client_"
  description = "Group for all clients"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "server" {
  vpc_id = aws_vpc.this.id
  name_prefix = "server_"
  description = "Group for all servers"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "tcp_server_from_client" {
  description              = "Allow TCP ingress to clients from servers"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.server.id
  source_security_group_id = aws_security_group.client.id
}

resource "aws_security_group_rule" "ping_server_from_client" {
  description              = "Allow ICMP ingress to clients from servers"
  type                     = "ingress"
  from_port                = "-1"
  to_port                  = "-1"
  protocol                 = "icmp"
  security_group_id        = aws_security_group.server.id
  source_security_group_id = aws_security_group.client.id
}

resource "aws_security_group_rule" "client_to_server" {
  description              = "Allow TCP egress from clients to servers"
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.client.id
  source_security_group_id = aws_security_group.server.id
}
