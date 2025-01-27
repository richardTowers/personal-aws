resource "aws_route53_zone" "this" {
  name = "deliberatepractice.dev"
}

resource "aws_route53_record" "ec2_dns" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "${var.github_handle}.deliberatepractice.dev"
  type    = "A"
  ttl     = 300
  records = [aws_instance.ec2.public_ip]
}

output "name_servers" {
  value = aws_route53_zone.this.name_servers
}
