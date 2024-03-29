resource "github_repository" "aws-sns-to-ses-mailer" {
  name        = "aws-sns-to-ses-mailer"
  description = "AWS Lambda application to send emails via AWS SES using information recieved from AWS SNS notification"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true
  topics                 = concat(local.common_topics, local.aws_topics)

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "aws-sns-to-ses-mailer-dataworks" {
  repository = github_repository.aws-sns-to-ses-mailer.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "aws-sns-to-ses-mailer-master" {
  branch         = github_repository.aws-sns-to-ses-mailer.default_branch
  repository     = github_repository.aws-sns-to-ses-mailer.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "aws-sns-to-ses-mailer" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.aws-sns-to-ses-mailer.name
}

resource "github_actions_secret" "aws-sns-to-ses-mailer_github_email" {
  repository      = github_repository.aws-sns-to-ses-mailer.name
  secret_name     = "CI_GITHUB_EMAIL"
  plaintext_value = var.github_email
}

resource "github_actions_secret" "aws-sns-to-ses-mailer_github_username" {
  repository      = github_repository.aws-sns-to-ses-mailer.name
  secret_name     = "CI_GITHUB_USERNAME"
  plaintext_value = var.github_username
}

resource "github_actions_secret" "aws-sns-to-ses-mailer_github_token" {
  repository      = github_repository.aws-sns-to-ses-mailer.name
  secret_name     = "CI_GITHUB_TOKEN"
  plaintext_value = var.github_token
}

