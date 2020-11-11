module "aws_ami" {
  source = "../../amis/"
  os     = var.os
}

resource "aws_launch_configuration" "launchconf" {
  image_id        = "${module.aws_ami.image_id}"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instance.id]

  user_data = <<-EOF
        #!/bin/bash
        echo "Hello, World! `uname -a`" > index.html
        nohup busybox httpd -f -p "${var.server_port}" &
        EOF

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_availability_zones" "all" {
}

resource "aws_autoscaling_group" "asg" {
  launch_configuration = aws_launch_configuration.launchconf.id
  availability_zones   = data.aws_availability_zones.all.names

  min_size = 2
  max_size = 10

  load_balancers    = [aws_elb.elb.name]
  health_check_type = "ELB"

  # tag {
  #   key                 = "Name"
  #   value               = "terraform-asg-example"
  #   propagate_at_launch = true
  # }
}

resource "aws_elb" "elb" {
  # name               = "terraform-asg-example"
  availability_zones = data.aws_availability_zones.all.names
  security_groups    = [aws_security_group.elb.id]

  health_check {
    target              = "HTTP:${var.server_port}/"
    interval            = 5
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = var.server_port
    instance_protocol = "http"
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "elb" {
  name = "terraform-example-elb"
  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Inbound HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
