resource "aws_key_pair" "this" {
  key_name   = "richard-towers-ssh-ed25519"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "aws_instance" "this" {
  ami           = data.aws_ami.focal.id
  instance_type = "t3.nano"
  key_name      = aws_key_pair.this.key_name

  subnet_id                   = aws_subnet.this.id
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_egress.id,
  ]

  user_data = join("\n", [
    "#cloud-config",
    yamlencode({
      packages    = []
      write_files = []
    })
  ])

  tags = {
    Name = "prometheus-gmail-exporter"
  }
}

output "public_ip" {
  value = aws_instance.this.public_ip
}
