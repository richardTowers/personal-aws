data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "this" {
  key_name   = "arp-investigation"
  public_key = file("~/.ssh/arp-investigation.pub")
}

resource "aws_instance" "foo" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.this.key_name
  private_ip    = "10.0.0.11"

  subnet_id                   = aws_subnet.this.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [
    aws_security_group.foo.id,
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
    Name = "Foo"
  }
}

resource "aws_instance" "bar" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.this.key_name
  private_ip    = "10.0.0.5"

  subnet_id                   = aws_subnet.this.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [
    aws_security_group.bar.id,
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_egress.id,
  ]

  user_data = join("\n", [
    "#cloud-config",
    yamlencode({
      packages = ["net-tools", "apache2"]
      write_files = [{
        content = "Hello from Bar!\n"
        path    = "/var/www/html/index.html"
      }]
    })
  ])

  tags = {
    Name = "Bar"
  }
}
