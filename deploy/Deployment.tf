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

# manage Github users and OnCall Rotations
module "service_config" {
  source = "git@github.com:HappyPathway/ServiceConfig.git"
  admins = ["djaboxx"]
  devs = ["happymemes"]
  repo = "HappyMeme"
  nightshift_users = ["dja@sonic.net"]
  dayshift_users = ["dave@happypathway.com"]
  pagerduty_token = "${var.pagerduty_token}"
}

# manage dev environments
module "staging_proxy" {
  source = "git@github.com:HappyPathway/AwsConsulProxy.git"
  count = 1
  proxy_name = "app.ops.happypathway.com"
  region = "us-east-1"
  service_name = "app-proxy"
  service_version = "1.0.0"
}

module "staging_app_v101" {
  source = "git@github.com:HappyPathway/AwsConsulApp.git"
  count = 3
  service_version = "1.0.1"
  env = "staging"
  service_name = "app"
  region = "us-east-1"
}

module "staging_app_v102" {
  source = "git@github.com:HappyPathway/AwsConsulApp.git"
  count = 3
  service_version = "1.0.2"
  env = "staging"
  service_name = "app"
  region = "us-east-1"
}

output "staging_proxy" {
  value = "${module.staging_proxy.ip_addresses}"
}

output "staging_apps_v102" {
  value = "${module.staging_app_v102.ip_addresses}"
}

output "staging_apps_v101" {
  value = "${module.staging_app_v101.ip_addresses}"
}


