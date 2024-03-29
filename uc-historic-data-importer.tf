resource "github_repository" "uc-historic-data-importer" {
  name        = "uc-historic-data-importer"
  description = "Import UC mongo backup into hbase."

  allow_merge_commit     = false
  delete_branch_on_merge = true
  auto_init              = true
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "uc-historic-data-importer-dataworks" {
  repository = github_repository.uc-historic-data-importer.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "uc-historic-data-importer-master" {
  branch         = github_repository.uc-historic-data-importer.default_branch
  repository     = github_repository.uc-historic-data-importer.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "uc-historic-data-importer" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.uc-historic-data-importer.name
}

