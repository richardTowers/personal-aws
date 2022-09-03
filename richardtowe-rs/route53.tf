resource "aws_route53_zone" "this" {
  name = "richardtowe.rs"
}

resource "aws_route53_record" "apex" {
  zone_id = aws_route53_zone.this.zone_id
  name    = ""
  type    = "A"
  ttl     = "30"
  records = ["192.30.252.153", "192.30.252.154"]
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "www"
  type    = "A"
  ttl     = "30"
  records = ["192.30.252.153", "192.30.252.154"]
}

resource "aws_route53_record" "learn_to_pong" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "learn-to-pong"
  type    = "CNAME"
  ttl     = "30"
  records = ["richardtowers.github.io"]
}

output "name_servers" {
  value = aws_route53_zone.this.name_servers
}
