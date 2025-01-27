data "terraform_remote_state" "zone" {
  backend = "s3"

  config = {
    bucket = "personal-aws-tfstate"
    key    = "deliberatepractice-dev-zone"
    region = "eu-west-1"
  }
}

resource "aws_route53_record" "nlb_record" {
  for_each = aws_lb.nlb

  zone_id = data.terraform_remote_state.zone.outputs.zone_id
  name    = "${each.key}.deliberatepractice.dev"
  type    = "A"

  alias {
    name                   = each.value.dns_name
    zone_id                = each.value.zone_id
    evaluate_target_health = false
  }
}
