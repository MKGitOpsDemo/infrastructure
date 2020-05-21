data "aws_availability_zones" "all" {
}

module "aws_ami" {
  source = "../../amis/"
}

# This shouldnt be hard coded
# resource "aws_key_pair" "devops-admin-key" {
#   key_name   = "devops_admin_key"
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCywVlnfWLdOnPdaRzsawSqYVDmnD+VlKtbmhQy9C27tur3M99gOG+/O5mwGbjV2vmV6aIVkUIgEl9mzprjwJfYHOG+Jj1aqDVuuGR6T+HAMGNb5s/K21v3PvRueXwy8tN/tik6Jqpq+kELj/yX1KU8MKQkox5GQdEEvvcPzbEZrj9HfPSu51Sw2GOS13GUtppEXgKIoRZA1D/iLaWgcx4rRD2ttyp09JpHrgNWdnUEF5CQ5yE5xLvQtLsc09huZcgxEkTI/IpDlsv224mmUN+HbDfhoU6kowvPLBrIWzjxR3do9wSv6bnPajAJCLbx+YjDikH6tGviJ4APhe1RRiZZ"
# }

resource "aws_instance" "mgmthost" {
  ami                    = module.aws_ami.image_ids["ubuntu-disco"]
  instance_type          = "t2.micro"
  key_name               = "devops_admin_key"
  vpc_security_group_ids = [aws_security_group.mgmt_node.id]

  user_data = <<-EOF
        #!/bin/bash
        sudo apt update
        sudo apt-get -y install software-properties-common
        sudo apt-add-repository --yes --update ppa:ansible/ansible
        sudo apt-get -y install ansible
        ansible-pull -U "https://${var.git_user}:${var.git_pass}@${var.git_url}" bootstrap_mgmt.yml
        EOF

  tags = {
    "role" : "MgmtHost"
  }
}

resource "aws_launch_configuration" "launchconf" {
  for_each = var.tiers

  image_id        = module.aws_ami.image_ids[each.value.os]
  instance_type   = each.value.instance_type
  security_groups = [aws_security_group.instance[each.key].id]

  key_name = "devops_admin_key"

  # user_data = <<-EOF
  #       #!/bin/bash
  #       echo "Hello, World! `uname -a`" > index.html
  #       nohup busybox httpd -f -p "${concat(each.value.listeners.public, each.value.listeners.private)[0]}" &
  #       EOF

  user_data = <<-EOF
        #!/bin/bash
        sudo apt update
        sudo apt-get -y install software-properties-common
        sudo apt-add-repository --yes --update ppa:ansible/ansible
        sudo apt-get -y install ansible
        ansible-pull -U "https://${var.git_user}:${var.git_pass}@${var.git_url}" bootstrap_node.yml
        EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  for_each = var.tiers

  launch_configuration = aws_launch_configuration.launchconf["${each.key}"].id
  availability_zones   = data.aws_availability_zones.all.names

  min_size = 2
  max_size = 10

  load_balancers    = [aws_elb.elb[each.key].name]
  health_check_type = "ELB"

  tags = [
    {
      key                 = "role"
      value               = "WorkerNode"
      propagate_at_launch = true
    },
    {
      key                 = "nodeFlavour"
      value               = "${each.key}"
      propagate_at_launch = true
    },
  ]

}

resource "aws_elb" "elb" {
  for_each = var.tiers

  # name               = "terraform-asg-example"
  availability_zones = data.aws_availability_zones.all.names
  security_groups    = [aws_security_group.elb[each.key].id]

  # Note health check only monitors the first listener port
  health_check {
    target              = "TCP:${concat(each.value.listeners.public, each.value.listeners.private)[0]}"
    interval            = 5
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  dynamic "listener" {
    for_each = concat(each.value.listeners.public, each.value.listeners.private)
    content {
      lb_port           = listener.value
      instance_port     = listener.value
      lb_protocol       = "tcp"
      instance_protocol = "tcp"
    }
  }
}

data "aws_route53_zone" "primary" {
  name = "a.yktconsulting.com"
}

resource "aws_route53_record" "mgmthost" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "mgmt.${var.stack_ref}.a.yktconsulting.com"
  type    = "A"
  ttl     = "60"
  records = ["${aws_instance.mgmthost.public_ip}"]
}

resource "aws_route53_record" "tiers" {
  for_each = var.tiers

  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "${each.key}.${var.stack_ref}.a.yktconsulting.com"
  type    = "CNAME"
  ttl     = "60"
  records = ["${aws_elb.elb[each.key].dns_name}"]
}

resource "aws_security_group" "mgmt_node" {
  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Enable inbound SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // This is wrong
  }
}

resource "aws_security_group" "instance" {
  for_each = var.tiers

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = each.value.listeners.public
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Note that port 22 is hard-coded
  dynamic "ingress" {
    for_each = concat(each.value.listeners.private, [22])
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] // This is wrong
    }
  }
}

resource "aws_security_group" "elb" {
  for_each = var.tiers

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = each.value.listeners.public
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "ingress" {
    for_each = each.value.listeners.private
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] // This is wrong
    }
  }

}
