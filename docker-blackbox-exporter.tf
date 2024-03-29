resource "github_repository" "blackbox_exporter" {
  name             = "blackbox-exporter"
  description      = "blackbox_exporter"
  auto_init        = false

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner = var.github_organization
    repository = "dataworks-repo-template-docker"
  }
}

resource "github_team_repository" "blackbox_exporter_dataworks" {
  repository = github_repository.blackbox_exporter.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "blackbox_exporter_master" {
  branch         = github_repository.blackbox_exporter.default_branch
  repository     = github_repository.blackbox_exporter.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "blackbox_exporter" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.blackbox_exporter.name
}

resource "null_resource" "blackbox_exporter" {
  triggers = {
    repo = github_repository.blackbox_exporter.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.blackbox_exporter.name} '${github_repository.blackbox_exporter.description}' ${github_repository.blackbox_exporter.template.0.repository}"
  }
}

resource "github_actions_secret" "blackbox_exporter_dockerhub_password" {
  repository      = github_repository.blackbox_exporter.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = var.dockerhub_password
}

resource "github_actions_secret" "blackbox_exporter_dockerhub_username" {
  repository      = github_repository.blackbox_exporter.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = var.dockerhub_username
}

resource "github_actions_secret" "blackbox_exporter_snyk_token" {
  repository      = github_repository.blackbox_exporter.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}
