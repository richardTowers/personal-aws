data "http" "github_public_key" {
  for_each = local.github_users
  url      = "https://github.com/${each.value}.keys"
}

data "template_file" "ssh_key" {
  for_each = data.http.github_public_key
  template = each.value.response_body
}