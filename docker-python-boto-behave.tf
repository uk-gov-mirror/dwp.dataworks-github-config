resource "github_repository" "docker-python-boto-behave" {
  name        = "docker-python-boto-behave"
  description = "Docker python/3.7-alpine image with Boto and Behave."

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "docker-python-boto-behave-dataworks" {
  repository = github_repository.docker-python-boto-behave.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "docker-python-boto-behave-master" {
  branch         = github_repository.docker-python-boto-behave.default_branch
  repository     = github_repository.docker-python-boto-behave.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "docker-python-boto-behave" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.docker-python-boto-behave.name
}

