variable "pagerduty_token" {}
variable "github_token" {}
variable "github_organization" {}

# The variables in this file are being set through environment variables
provider "github" {
  token        = "${var.github_token}"
  organization = "${var.github_organization}"
}

provider "pagerduty" {
  token = "${var.pagerduty_token}"
}

module "service_config" {
  source = "git@github.com:HappyPathway/ServiceConfig.git"
  admins = ["djaboxx"]
  devs = ["happymemes"]
  repo = "HappyMeme"
  nightshift_users = ["dja@sonic.net"]
  dayshift_users = ["dave@happypathway.com"]
  pagerduty_token = "${var.pagerduty_token}"
}
  
