resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_config_map" "argocd-cm" {
  metadata {
    name      = "argocd-cm"
    namespace = "argocd"
    labels = {
      "app.kubernetes.io/name"    = "argocd-cm"
      "app.kubernetes.io/part-of" = "argocd"
    }
  }

  data = {
    "url" : "https://argocd.maikbuse.com"
    "admin.enabled" : "false"
    "oidc.config"         = <<-EOT
      name: Keycloak
      issuer: https://keycloak.maikbuse.com/realms/home
      clientID: argocd
      clientSecret: $oidc.keycloak.clientSecret
      requestedScopes: ["openid", "profile", "email", "groups"]
    EOT
    "resource.exclusions" = <<-EOT
    - apiGroups:
        - cilium.io
      kinds:
        - CiliumIdentity
      clusters:
        - "*"
    EOT
  }

  depends_on = [kubernetes_namespace.argocd]
}

resource "kubernetes_config_map" "argocd-rbac-cm" {
  metadata {
    name      = "argocd-rbac-cm"
    namespace = "argocd"
    labels = {
      "app.kubernetes.io/name"    = "argocd-rbac-cm"
      "app.kubernetes.io/part-of" = "argocd"
    }
  }

  data = {
    "policy.csv" = <<-EOT
      g, Admins, role:admin
    EOT
  }

  depends_on = [kubernetes_namespace.argocd]
}

resource "helm_release" "argocd" {
  name = "argocd"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.7.14"

  namespace = "argocd"

  reset_values = true

  set {
    name  = "configs.cm.create"
    value = false
  }

  set {
    name  = "configs.rbac.create"
    value = false
  }

  # Needed in order to make ingress work
  set {
    name  = "configs.params.server.insecure"
    value = true
  }

  depends_on = [
    kubernetes_namespace.argocd,
    kubernetes_config_map.argocd-cm,
    kubernetes_config_map.argocd-rbac-cm
  ]
}

resource "kubectl_manifest" "app-of-apps" {
  yaml_body = file("${path.module}/manifests/argocd-app-of-apps.yaml")

  depends_on = [helm_release.argocd]
}
