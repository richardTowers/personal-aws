resource "aws_route53_zone" "this" {
  name = "deliberatepractice.dev"
}

output "name_servers" {
  value = aws_route53_zone.this.name_servers
}
