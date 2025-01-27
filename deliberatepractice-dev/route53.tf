data "terraform_remote_state" "zone" {
  backend = "s3"

  config = {
    bucket = "personal-aws-tfstate"
    key    = "deliberatepractice-dev-zone"
    region = "eu-west-1"
  }
}

resource "aws_route53_record" "ec2_dns" {
  zone_id = data.terraform_remote_state.zone.outputs.zone_id
  name    = "${var.github_handle}.deliberatepractice.dev"
  type    = "A"
  ttl     = 300
  records = [aws_instance.ec2.public_ip]
}
