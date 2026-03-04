data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "http" "my_public_ip" { url = "https://checkip.amazonaws.com/" }
locals {
  my_public_ip_cidr = "${trimspace(data.http.my_public_ip.response_body)}/32"
  app_name          = "event-response-app"
}
