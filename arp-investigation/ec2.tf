resource "aws_key_pair" "this" {
  key_name   = "arp-investigation"
  public_key = file("~/.ssh/arp-investigation.pub")
}

resource "aws_instance" "client" {
  ami           = data.aws_ami.trusty.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.this.key_name
  private_ip    = "10.0.0.10"

  subnet_id                   = aws_subnet.this.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [
    aws_security_group.client.id,
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_egress.id,
  ]

  user_data = join("\n", [
    "#cloud-config",
    yamlencode({
      packages = ["net-tools"]
    })
  ])

  tags = {
    Name = "Trusty client"
  }
}

resource "aws_instance" "server" {
  for_each = {
    a = "10.0.0.12"
    b = "10.0.0.13"
  }

  ami           = data.aws_ami.focal.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.this.key_name
  private_ip    = each.value

  subnet_id                   = aws_subnet.this.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [
    aws_security_group.server.id,
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_egress.id,
  ]

  user_data = join("\n", [
    "#cloud-config",
    yamlencode({
      packages = ["apache2"]
      write_files = [{
        content = "Hello from Server ${title(each.key)}\n"
        path    = "/var/www/html/index.html"
      }]
    })
  ])

  tags = {
    Name = "Server ${title(each.key)}"
  }
}

output "client_public_ip" {
  value = aws_instance.client.public_ip
}
