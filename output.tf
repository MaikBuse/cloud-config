output "kubeconfig" {
  sensitive = true
  value     = module.kube-hetzner.kubeconfig
}
