data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_launch_template" "this" {
  for_each = data.template_file.ssh_key

  name = "${each.key}-launch-template"

  instance_type = "t3.micro"
  image_id      = data.aws_ami.amazon_linux.image_id

  network_interfaces {
    subnet_id                   = aws_subnet.this.id
    associate_public_ip_address = false
    security_groups             = [aws_security_group.ssh_and_https.id]
  }

  user_data = base64encode(
    <<-EOF
    #!/bin/bash
    echo "${each.value.rendered}" > /home/ec2-user/.ssh/authorized_keys
    chown ec2-user:ec2-user /home/ec2-user/.ssh/authorized_keys
    chmod 600 /home/ec2-user/.ssh/authorized_keys
    EOF
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  for_each = aws_launch_template.this

  launch_template {
    id      = each.value.id
    version = "$Latest"
  }

  min_size         = 0
  max_size         = 1
  desired_capacity = 1

  vpc_zone_identifier = [aws_subnet.this.id]

  tag {
    key                 = "Name"
    value               = "${each.key}.deliberatepractice.dev"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Scale up at 9:00 AM London time
resource "aws_autoscaling_schedule" "scale_up" {
  for_each = aws_autoscaling_group.this

  autoscaling_group_name = each.value.name
  scheduled_action_name  = "ScaleUp"
  min_size               = 1
  max_size               = 1
  desired_capacity       = 1

  recurrence = "0 9 * * 1-5" # Cron format: 9:00 AM Monday to Friday (London time)
}

# Scale down at 5:00 PM London time
resource "aws_autoscaling_schedule" "scale_down" {
  for_each = aws_autoscaling_group.this

  autoscaling_group_name = each.value.name
  scheduled_action_name  = "ScaleDown"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0

  recurrence = "0 17 * * 1-5" # Cron format: 5:00 PM Monday to Friday (London time)
}
