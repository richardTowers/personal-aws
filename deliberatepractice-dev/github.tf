data "http" "github_public_key" {
  url = "https://github.com/${var.github_handle}.keys"
}

data "template_file" "ssh_key" {
  template = data.http.github_public_key.body
}