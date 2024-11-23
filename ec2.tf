# Security group for ALB
resource "aws_security_group" "alb_sg" {
    name = "sun-alb-sg"
    description = "Security Group for application load balancer"
    vpc_id = aws_vpc.us_vpc.id

    
    tags = {
      name = "sun-alb-sg"
    }
}

resource "aws_security_group_rule" "alb_sg_ingress_http" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}

# Security group for ec2 instance
resource "aws_security_group" "ec2_sg" {
    name = "sun-ec2-sg"
    description = "Security Group for Web server Instance"
    vpc_id = aws_vpc.us_vpc.id


    tags = {
        name = "sun-ec2-sg"
    }
  
}

resource "aws_security_group_rule" "ec2_sg_ingress_from_alb" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
  security_group_id = aws_security_group.ec2_sg.id
}

resource "aws_security_group_rule" "ec2_sg_ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["Your ip address/32"] #Your IP address
  security_group_id = aws_security_group.ec2_sg.id
}

# Application load balancer
resource "aws_lb" "app_alb" {
    name = "sun-app-alb"
    load_balancer_type = "application"
    internal = false
    security_groups = [ aws_security_group.alb_sg.id ]
    subnets = aws_subnet.public_subnet[*].id
    depends_on = [ aws_internet_gateway.igw_vpc ]
  
}

#Target group for alb
resource "aws_lb_target_group" "alb_ec2_tg" {
    name = "sun-web-server-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.us_vpc.id
    tags = {
      name = "sun-alb_ec2_tg"
    }
  
}

resource "aws_lb_listener" "lb_listener" {
    load_balancer_arn = aws_lb.app_alb.arn
    port = "80"
    protocol = "HTTP"
    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.alb_ec2_tg.arn
    }
    tags = {
      name = "sun-alb-listener"
    }
  
}


resource "aws_launch_template" "ec2_launch_template" {
  name = "sun-web-server"
  image_id = "ami-0866a3c8686eaeeba"
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2_sg.id]
  }

  user_data = filebase64("userdata.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      name = "sun-ec2-web-server"
    }
  }
  
}

resource "aws_autoscaling_group" "ec2_asg" {
  name = "sun-web-server-asg"
  desired_capacity = 1
  min_size = 1
  max_size = 2
  target_group_arns = [aws_lb_target_group.alb_ec2_tg.arn]
  vpc_zone_identifier = aws_subnet.public_subnet[*].id

  launch_template {
    id = aws_launch_template.ec2_launch_template.id
    version = "$Latest"
    
  }  

  health_check_type = "EC2"
}

data "aws_instances" "asg_instances" {
  instance_tags = {
    name = "sun-ec2-web-server"
  }

  depends_on = [aws_autoscaling_group.ec2_asg]
}