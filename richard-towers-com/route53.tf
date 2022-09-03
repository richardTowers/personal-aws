resource "aws_route53_zone" "this" {
  name = "richard-towers.com"
}

resource "aws_route53_record" "apex_a" {
  zone_id = aws_route53_zone.this.zone_id
  name    = ""
  type    = "A"
  ttl     = "30"
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
  ttl     = "30"
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
  type    = "CNAME"
  ttl     = "30"
  records = ["richardtowers.github.io"]
}

resource "aws_route53_record" "mx" {
  zone_id = aws_route53_zone.this.zone_id
  name    = ""
  type    = "MX"
  ttl     = "30"
  records = [
    "1 aspmx.l.google.com",
    "5 alt1.aspmx.l.google.com",
    "5 alt2.aspmx.l.google.com",
    "10 alt3.aspmx.l.google.com",
    "10 alt4.aspmx.l.google.com"
  ]
}

resource "aws_route53_record" "dmarc" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "_dmarc"
  type    = "TXT"
  ttl     = "30"
  records = ["v=DMARC1; p=none; rua=mailto:richard_towers@yahoo.co.uk"]
}

resource "aws_route53_record" "apex_txt" {
  zone_id = aws_route53_zone.this.zone_id
  name    = ""
  type    = "TXT"
  ttl     = "30"
  records = [
    "v=spf1 ip4:66.96.128.0/18 ?all",
    "keybase-site-verification=j-z_9pR3s7aVX46B_YSrDMHd7bR90VxjyPLXnTlfUL0"
  ]
}

resource "aws_route53_record" "github_pages_challenge" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "_github-pages-challenge-richardtowers"
  type    = "TXT"
  ttl     = "30"
  records = ["426db6ed0f0769fae5fe33f996e9ba"]
}

output "name_servers" {
  value = aws_route53_zone.this.name_servers
}
