resource "github_repository" "aws-cloudwatch-alerting" {
  name        = "aws-cloudwatch-alerting"
  description = "Lambda function to send CloudWatch alerts to Slack"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  auto_init              = true
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "aws-cloudwatch-alerting-dataworks" {
  repository = github_repository.aws-cloudwatch-alerting.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "aws-cloudwatch-alerting-master" {
  branch         = github_repository.aws-cloudwatch-alerting.default_branch
  repository     = github_repository.aws-cloudwatch-alerting.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "aws-cloudwatch-alerting" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.aws-cloudwatch-alerting.name
}

resource "github_actions_secret" "aws-cloudwatch-alerting_github_email" {
  repository      = github_repository.aws-cloudwatch-alerting.name
  secret_name     = "CI_GITHUB_EMAIL"
  plaintext_value = var.github_email
}

resource "github_actions_secret" "aws-cloudwatch-alerting_github_username" {
  repository      = github_repository.aws-cloudwatch-alerting.name
  secret_name     = "CI_GITHUB_USERNAME"
  plaintext_value = var.github_username
}

resource "github_actions_secret" "aws-cloudwatch-alerting_github_token" {
  repository      = github_repository.aws-cloudwatch-alerting.name
  secret_name     = "CI_GITHUB_TOKEN"
  plaintext_value = var.github_token
}

