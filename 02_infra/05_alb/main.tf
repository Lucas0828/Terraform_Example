
#Launch Template
resource "aws_launch_template" "example" {
  name = "aws15-example-template"
  image_id = "ami-0aa87027ae932fe92"
  instance_type = "t2.micro"
  key_name = "aws15-key"
  vpc_security_group_ids = [ aws_security_group.web.id, aws_security_group.ssh.id ]
  user_data = "${base64encode(data.template_file.web_output.rendered)}"
  lifecycle {
    create_before_destroy = true
  }
}

#Autoscaling
resource "aws_autoscaling_group" "example" {
  availability_zones = [ "ap-northeast-2a","ap-northeast-2c" ]
  # vpc_zone_identifier = [ "subnet-0f02b373f7f78e4a2", "subnet-09f682d70ced2e4a1" ]
	# vpc_zone_identifier = [var.ap-northeast-2a,var.ap-northeast-2c]
  name = "aws15-asg-example"
  desired_capacity = 1
  min_size = 1
  max_size = 2
  target_group_arns = [ aws_lb_target_group.asg.arn ]
  health_check_type = "ELB"
  launch_template {
    id = aws_launch_template.example.id
    version = "$Latest"
  }

  tag {
    key = "Name"
    value = "aws15-asg-example"
    propagate_at_launch = true
  }
}

#Application Load Balancer
resource "aws_lb" "example" {
  name = "aws15-alb-example"
  load_balancer_type = "application"
  subnets = data.aws_subnets.default.ids
  security_groups = [aws_security_group.alb.id]
}

#Application Load Balancer Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port = 8080
  protocol = "HTTP"
  default_action {
   type =  "fixed-response"
   fixed_response {
     content_type = "text/plain"
     message_body = "404: page not found"
     status_code = 404
   }
  }
}

#Application Load Balancer Listener Rule
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100
  condition {
    path_pattern {
      values = [ "*" ]
    }
  }
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

#Load Balancer Taget Group
resource "aws_lb_target_group" "asg" {
  name = "aws15-target-group-example"
  port = var.web_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id
  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

#Security Application Load Balancer
resource "aws_security_group" "alb" {
 name = "aws15-sg-example-alb" 
 ingress{
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
 }
 egress{
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [ "0.0.0.0/0" ]
 }
}

resource "aws_security_group" "web" {
  name = "aws15-example-web"
  ingress{
    from_port = var.web_port
    to_port = var.web_port
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "aws_security_group" "ssh" {
  name = "aws15-example-ssh" 
  ingress{
    from_port = var.ssh_port
    to_port = var.ssh_port
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [ data.aws_vpc.default.id ]
  }
}

data "template_file" "web_output" {
  template = file("${path.module}/web.sh")
  vars = {
    web_port = "${var.web_port}"
  }
}