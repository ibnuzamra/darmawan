output "vpc_id" { value = aws_vpc.this.id }
output "public_subnet_ids" { value = values(aws_subnet.public)[*].id }
output "private_subnet_ids" { value = values(aws_subnet.private)[*].id }
output "alb_security_group_id" { value = aws_security_group.alb.id }
output "application_security_group_id" { value = aws_security_group.application.id }
output "database_security_group_id" { value = aws_security_group.database.id }
