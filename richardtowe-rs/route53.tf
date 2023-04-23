resource "aws_route53_zone" "this" {
  name = "richardtowe.rs"
}

resource "aws_route53_record" "apex_a" {
  zone_id = aws_route53_zone.this.zone_id
  name    = ""
  type    = "A"
  ttl     = 30
  records = [
    "185.199.108.153",
    "185.199.109.153",
    "185.199.110.153",
    "185.199.111.153",
  ]
}

resource "aws_route53_record" "apex_aaaa" {
  zone_id = aws_route53_zone.this.zone_id
  name    = ""
  type    = "AAAA"
  ttl     = 30
  records = [
    "2606:50c0:8000::153",
    "2606:50c0:8001::153",
    "2606:50c0:8002::153",
    "2606:50c0:8003::153",
  ]
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "www"
  type    = "A"
  ttl     = 30
  records = [
    "192.30.252.153",
    "192.30.252.154",
  ]
}

resource "aws_route53_record" "learn_to_pong" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "learn-to-pong"
  type    = "CNAME"
  ttl     = "30"
  records = ["richardtowers.github.io"]
}

resource "aws_route53_record" "the_training_mews" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "the-training-mews"
  type    = "CNAME"
  ttl     = "30"
  records = ["richardtowers.github.io"]
}

output "name_servers" {
  value = aws_route53_zone.this.name_servers
}
