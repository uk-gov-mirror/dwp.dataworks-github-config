resource "github_repository" "docker_tflint" {
  name        = "docker-tflint"
  description = "alpine container with bash, tflint, ca-certs and jq baked in"
  auto_init   = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner      = var.github_organization
    repository = "dataworks-repo-template-docker"
  }
}

resource "github_team_repository" "docker_tflint_dataworks" {
  repository = github_repository.docker_tflint.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "docker_tflint_master" {
  branch         = github_repository.docker_tflint.default_branch
  repository     = github_repository.docker_tflint.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "docker_tflint" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.docker_tflint.name
}

resource "null_resource" "docker_tflint" {
  triggers = {
    repo = github_repository.docker_tflint.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.docker_tflint.name} '${github_repository.docker_tflint.description}' ${github_repository.docker_tflint.template.0.repository}"
  }
}

resource "github_actions_secret" "docker_tflint_dockerhub_password" {
  repository      = github_repository.docker_tflint.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = var.dockerhub_password
}

resource "github_actions_secret" "docker_tflint_dockerhub_username" {
  repository      = github_repository.docker_tflint.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = var.dockerhub_username
}

resource "github_actions_secret" "docker_tflint_snyk_token" {
  repository      = github_repository.docker_tflint.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}
