resource "github_repository" "snapshot-sender" {
  name        = "snapshot-sender"
  description = "Decrypts and delivers mongo exports created by hbase-to-mongo-export"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "snapshot-sender-dataworks" {
  repository = github_repository.snapshot-sender.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "mongo-export-delivery-master" {
  branch         = github_repository.snapshot-sender.default_branch
  repository     = github_repository.snapshot-sender.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "snapshot-sender" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.snapshot-sender.name
}

