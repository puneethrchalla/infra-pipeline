resource "aws_elb" "app_elb" {
  name                        = "${var.project}-${var.environment}-${var.app_elb_name}"
  security_groups             = ["${aws_security_group.app_elb_sg.id}"]
  subnets                     = ["${element(split(",", data.terraform_remote_state.layer_network.App_Subnet_ID), 0)}", "${element(split(",", data.terraform_remote_state.layer_network.App_Subnet_ID), 1)}"]
  connection_draining         = false
  connection_draining_timeout = "300"
  cross_zone_load_balancing   = true
  idle_timeout                = "60"
  internal                    = true

  health_check = {
    healthy_threshold   = 2
    interval            = 30
    target              = "TCP:80"
    timeout             = 5
    unhealthy_threshold = 5
  }

  listener = {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener = {
    instance_port     = 9000
    instance_protocol = "tcp"
    lb_port           = 9000
    lb_protocol       = "tcp"
  }

  listener = {
    instance_port     = 9001
    instance_protocol = "tcp"
    lb_port           = 9001
    lb_protocol       = "tcp"
  }

  listener = {
    instance_port     = 9002
    instance_protocol = "tcp"
    lb_port           = 9002
    lb_protocol       = "tcp"
  }

  listener = {
    instance_port     = 9003
    instance_protocol = "tcp"
    lb_port           = 9003
    lb_protocol       = "tcp"
  }

  listener = {
    instance_port     = 9004
    instance_protocol = "tcp"
    lb_port           = 9004
    lb_protocol       = "tcp"
  }

  tags = {
    Name        = "${var.project}-${var.environment}-${var.app_elb_name}"
    Owner       = "${var.owner}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}

resource "aws_elb" "web_elb" {
  name                        = "${var.project}-${var.environment}-${var.web_elb_name}"
  security_groups             = ["${aws_security_group.web_elb_sg.id}"]
  subnets                     = ["${element(split(",", data.terraform_remote_state.layer_network.DMZ_Subnet_ID), 0)}", "${element(split(",", data.terraform_remote_state.layer_network.DMZ_Subnet_ID), 1)}"]
  connection_draining         = false
  connection_draining_timeout = "300"
  cross_zone_load_balancing   = true
  idle_timeout                = "60"
  internal                    = false

  health_check = {
    healthy_threshold   = 2
    interval            = 30
    target              = "TCP:443"
    timeout             = 5
    unhealthy_threshold = 5
  }

  listener = {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener = {
    instance_port     = 443
    instance_protocol = "tcp"
    lb_port           = 443
    lb_protocol       = "tcp"
  }

  tags = {
    Name        = "${var.project}-${var.environment}-${var.web_elb_name}"
    Owner       = "${var.owner}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}

resource "aws_load_balancer_policy" "web_elb_policy" {
  load_balancer_name = "${aws_elb.web_elb.name}"
  policy_name        = "my-ProxyProtocol-policy"
  policy_type_name   = "ProxyProtocolPolicyType"

  policy_attribute = {
    name  = "ProxyProtocol"
    value = "true"
  }
}

resource "aws_load_balancer_backend_server_policy" "web_elb_backend_server_policy" {
  load_balancer_name = "${aws_elb.web_elb.name}"
  instance_port      = 443

  policy_names = [
    "${aws_load_balancer_policy.web_elb_policy.policy_name}",
  ]
}

resource "aws_elb" "static_cluster_elb" {
  name                        = "${var.project}-${var.environment}-${var.static_cluster_elb_name}"
  security_groups             = ["${aws_security_group.static_cluster_elb_sg.id}"]
  subnets                     = ["${element(split(",", data.terraform_remote_state.layer_network.App_Subnet_ID), 0)}", "${element(split(",", data.terraform_remote_state.layer_network.App_Subnet_ID), 1)}"]
  connection_draining         = false
  connection_draining_timeout = "300"
  cross_zone_load_balancing   = true
  idle_timeout                = "60"
  internal                    = true

  health_check = {
    healthy_threshold   = 2
    interval            = 30
    target              = "TCP:15672"
    timeout             = 5
    unhealthy_threshold = 5
  }

  listener = {
    instance_port     = 2181
    instance_protocol = "tcp"
    lb_port           = 2181
    lb_protocol       = "tcp"
  }

  listener = {
    instance_port     = 2888
    instance_protocol = "tcp"
    lb_port           = 2888
    lb_protocol       = "tcp"
  }

  listener = {
    instance_port     = 25672
    instance_protocol = "tcp"
    lb_port           = 25672
    lb_protocol       = "tcp"
  }

  listener = {
    instance_port     = 5050
    instance_protocol = "tcp"
    lb_port           = 5050
    lb_protocol       = "tcp"
  }

  listener = {
    instance_port     = 4369
    instance_protocol = "tcp"
    lb_port           = 4369
    lb_protocol       = "tcp"
  }

  listener = {
    instance_port     = 5672
    instance_protocol = "tcp"
    lb_port           = 5672
    lb_protocol       = "tcp"
  }

  listener = {
    instance_port     = 7099
    instance_protocol = "tcp"
    lb_port           = 7099
    lb_protocol       = "tcp"
  }

  listener = {
    instance_port     = 3888
    instance_protocol = "tcp"
    lb_port           = 3888
    lb_protocol       = "tcp"
  }

  listener = {
    instance_port     = 15672
    instance_protocol = "tcp"
    lb_port           = 15672
    lb_protocol       = "tcp"
  }

  listener = {
    instance_port     = 15674
    instance_protocol = "tcp"
    lb_port           = 15674
    lb_protocol       = "tcp"
  }

  tags = {
    Name        = "${var.project}-${var.environment}-${var.static_cluster_elb_name}"
    Owner       = "${var.owner}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}
