resource "aws_route53_zone" "this" {
  name = "formal.dev"
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
  type    = "CNAME"
  ttl     = "30"
  records = ["formal-dev.github.io"]
}

resource "aws_route53_record" "github_pages_challenge" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "_github-pages-challenge-formal-dev"
  type    = "TXT"
  ttl     = "30"
  records = ["d78706cadcd67727da6b36d083a466"]
}

output "name_servers" {
  value = aws_route53_zone.this.name_servers
}
