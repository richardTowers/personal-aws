data "aws_route53_zone" "this" {
  name = "bowman.dog."
}

resource "aws_route53_record" "rory" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "rory"
  type    = "CNAME"
  ttl     = "30"
  records = ["richardtowers.github.io"]
}

