resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.51.6" # Use latest stable version or pin as needed
}


resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.10.0" # Pin to a stable version

  values = [
    <<-EOF
    controller:
      replicaCount: 2
      service:
        type: LoadBalancer
      nodeSelector:
        agentpool: publicpool
    EOF
  ]
}


resource "azurerm_kubernetes_cluster_node_pool" "publicpool" {
  name                  = "publicpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  vm_size               = "Standard_B2s"
  node_count            = 2
  os_disk_size_gb       = 30
  vnet_subnet_id        = azurerm_subnet.public.id
  mode                  = "User"
  orchestrator_version  = "1.31.8" # Or whatever your current AKS version is

  node_labels = {
    agentpool = "publicpool"
  }

  upgrade_settings {
    max_surge = "33%"
  }

  tags = {
    environment = "public"
  }
}

