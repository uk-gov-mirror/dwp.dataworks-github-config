resource "github_repository" "docker-jinja-yaml-aws" {
  name        = "docker-jinja-yaml-aws"
  description = "Docker container with Jinja2, YAML and AWS SDK for populating templates with values from AWS"

  allow_merge_commit = false
  auto_init          = true
  has_issues         = true

  lifecycle {
    prevent_destroy = false
  }
}

resource "github_team_repository" "docker-jinja-yaml-aws-dataworks" {
  repository = "${github_repository.docker-jinja-yaml-aws.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "admin"
}

resource "github_branch_protection" "docker-jinja-yaml-aws-master" {
  branch         = "${github_repository.docker-jinja-yaml-aws.default_branch}"
  repository     = "${github_repository.docker-jinja-yaml-aws.name}"
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}