data "terraform_remote_state" "zone" {
  backend = "s3"

  config = {
    bucket = "personal-aws-tfstate"
    key    = "deliberatepractice-dev-zone"
    region = "eu-west-1"
  }
}

resource "aws_route53_record" "ec2_dns" {
  for_each = aws_instance.ec2
  zone_id  = data.terraform_remote_state.zone.outputs.zone_id
  name     = "${each.key}.deliberatepractice.dev"
  type     = "A"
  ttl      = 300
  records  = [each.value.public_ip]
}
