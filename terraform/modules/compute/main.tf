data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_iam_role" "instance" {
  name = "${var.name}-instance"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
resource "aws_iam_role_policy_attachment" "cw" {
  role       = aws_iam_role.instance.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
resource "aws_iam_role_policy" "app" {
  name = "${var.name}-app-access"
  role = aws_iam_role.instance.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        { Effect = "Allow", Action = ["secretsmanager:GetSecretValue"], Resource = [var.application_secret_arn, var.database_secret_arn] },
        { Effect = "Allow", Action = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"], Resource = "${var.uploads_bucket_arn}/*" },
        { Effect = "Allow", Action = ["s3:ListBucket"], Resource = var.uploads_bucket_arn }
      ],
      var.cicd_artifacts_bucket_arn != "" ? [
        {
          Effect   = "Allow"
          Action   = ["s3:GetObject", "s3:GetObjectVersion", "s3:ListBucket"]
          Resource = [var.cicd_artifacts_bucket_arn, "${var.cicd_artifacts_bucket_arn}/*"]
        }
      ] : []
    )
  })
}
resource "aws_iam_instance_profile" "this" {
  name = "${var.name}-profile"
  role = aws_iam_role.instance.name
}

resource "aws_lb" "this" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids
}
resource "aws_lb_target_group" "backend" {
  name     = "${var.name}-api"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path    = "/health"
    matcher = "200"
  }
}
resource "aws_lb_target_group" "frontend" {
  name     = "${var.name}-web"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path    = "/"
    matcher = "200-399"
  }
}
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}
resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

resource "aws_launch_template" "app" {
  for_each      = { backend = aws_lb_target_group.backend.arn, frontend = aws_lb_target_group.frontend.arn }
  name_prefix   = "${var.name}-${each.key}-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type
  iam_instance_profile { name = aws_iam_instance_profile.this.name }
  vpc_security_group_ids = [var.application_security_group_id]
  user_data = base64encode(templatefile("${path.module}/user_data.sh.tftpl", {
    image_uri              = var.image_uris[each.key]
    app_role               = each.key
    aws_region             = var.aws_region
    database_host          = var.database_host
    database_secret_arn    = var.database_secret_arn
    application_secret_arn = var.application_secret_arn
    redis_host             = var.redis_host
    uploads_bucket         = var.uploads_bucket_name
  }))
  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "${var.name}-${each.key}" }
  }
}
resource "aws_autoscaling_group" "app" {
  for_each                  = aws_launch_template.app
  name                      = "${var.name}-${each.key}"
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.private_subnet_ids
  target_group_arns         = [each.key == "backend" ? aws_lb_target_group.backend.arn : aws_lb_target_group.frontend.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300
  launch_template {
    id      = each.value.id
    version = each.value.latest_version
  }
  instance_refresh {
    strategy = "Rolling"
    preferences { min_healthy_percentage = 50 }
  }
}
