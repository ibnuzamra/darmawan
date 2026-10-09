output "repository_urls" {
  value = { for key, repo in aws_ecr_repository.app : key => repo.repository_url }
}

output "codebuild_project_names" {
  value = { for key, project in aws_codebuild_project.app : key => project.name }
}

output "codedeploy_app_names" {
  value = { for key, app in aws_codedeploy_app.app : key => app.name }
}

output "codedeploy_deployment_group_names" {
  value = { for key, group in aws_codedeploy_deployment_group.app : key => group.deployment_group_name }
}

output "codepipeline_names" {
  value = { for key, pipeline in aws_codepipeline.app : key => pipeline.name }
}

output "github_connection_arn" {
  value = aws_codestarconnections_connection.github.arn
}

