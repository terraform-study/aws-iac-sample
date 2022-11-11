terraform {
  required_providers {
    kubernetes = {}
    helm       = {}
  }
}

resource "kubernetes_labels" "cluster1_default" {
  api_version = "v1"
  kind        = "Namespace"
  metadata {
    name = "default"
  }
  labels = {
    istio-injection = "enabled"
  }
}


resource "kubernetes_namespace" "istio" {
  metadata {
    name = "istio-system"

    labels = {
      name = "istio-system"
    }
  }
}

resource "helm_release" "istio" {
  chart      = "base"
  name       = "istio-base"
  namespace  = "istio-system"
  repository = "https://istio-release.storage.googleapis.com/charts"
  depends_on = [
    kubernetes_namespace.istio
  ]
}

resource "helm_release" "istiod" {
  chart      = "istiod"
  name       = "istiod"
  namespace  = "istio-system"
  repository = "https://istio-release.storage.googleapis.com/charts"
  depends_on = [
    kubernetes_namespace.istio
  ]
}

resource "helm_release" "istio_ingress2" {
  chart      = "gateway"
  name       = "istio-ingress"
  namespace  = "default"
  repository = "https://istio-release.storage.googleapis.com/charts"
  depends_on = [
    helm_release.istio,
    helm_release.istiod
  ]
}

resource "helm_release" "telemetry" {
  chart     = "./helm/telemetry"
  name      = "telemetry"
  namespace = "istio-system"
}
