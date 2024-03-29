resource "github_repository" "dataworks_hardened_images" {
  name        = "dataworks-hardened-images"
  description = "Dataworks specific container images which remove vulnerabilities from their base."
  auto_init   = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "dataworks_hardened_images" {
  repository = github_repository.dataworks_hardened_images.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "dataworks_hardened_images_master" {
  branch         = github_repository.dataworks_hardened_images.default_branch
  repository     = github_repository.dataworks_hardened_images.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "dataworks_hardened_images" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.dataworks_hardened_images.name
}

resource "github_actions_secret" "dataworks_hardened_images_dockerhub_password" {
  repository      = github_repository.dataworks_hardened_images.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = var.dockerhub_password
}

resource "github_actions_secret" "dataworks_hardened_images_dockerhub_username" {
  repository      = github_repository.dataworks_hardened_images.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = var.dockerhub_username
}

resource "github_actions_secret" "dataworks_hardened_images_snyk_token" {
  repository      = github_repository.dataworks_hardened_images.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}

