variable "hcloud_token" {
  sensitive = true
}

variable "source_addresses" {
  default = ["0.0.0.0/0", "::/0"]
  type    = list(string)
}
