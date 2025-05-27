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
  version    = "4.10.0"

  values = [
    <<-EOF
    controller:
      replicaCount: 2
      service:
        type: LoadBalancer
      nodeSelector:
        agentpool: publicpool
      tolerations:
        - key: "ingress"
          operator: "Equal"
          value: "true"
          effect: "NoSchedule"
    EOF
  ]
}


resource "azurerm_kubernetes_cluster_node_pool" "public" {
  name                  = "publicpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 1
  vnet_subnet_id        = azurerm_subnet.public.id
  orchestrator_version  = azurerm_kubernetes_cluster.k8s.kubernetes_version
  mode                  = "User"

  node_labels = {
    agentpool = "publicpool"
  }

  node_taints = ["ingress=true:NoSchedule"]
}

