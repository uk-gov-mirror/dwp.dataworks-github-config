resource "github_repository" "cognito-guacamole-extension" {
  name        = "cognito-guacamole-extension"
  description = "Integration between cognito and Apache Guacamole"
  auto_init   = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "cognito-guacamole-extension-dataworks" {
  repository = github_repository.cognito-guacamole-extension.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "cognito-guacamole-extension-master" {
  branch         = github_repository.cognito-guacamole-extension.default_branch
  repository     = github_repository.cognito-guacamole-extension.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "cognito-guacamole-extension" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.cognito-guacamole-extension.name
}

resource "github_actions_secret" "cognito-guacamole-extension-dockerhub-password" {
  repository      = github_repository.cognito-guacamole-extension.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = var.dockerhub_password
}

resource "github_actions_secret" "cognito-guacamole-extension-dockerhub-username" {
  repository      = github_repository.cognito-guacamole-extension.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = var.dockerhub_username
}

resource "github_actions_secret" "cognito-guacamole-extension-snyk-token" {
  repository      = github_repository.cognito-guacamole-extension.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}

resource "github_actions_secret" "cognito-guacamole-extension-slack-webhook" {
  repository      = github_repository.cognito-guacamole-extension.name
  secret_name     = "SLACK_WEBHOOK"
  plaintext_value = var.slack_webhook_url
}

