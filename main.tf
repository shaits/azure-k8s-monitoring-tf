
resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = var.resource_group_name
}

resource "azurerm_user_assigned_identity" "aks_uami" {
  name                = "aks-identity"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_kubernetes_cluster" "k8s" {
  location            = azurerm_resource_group.rg.location
  name                = var.cluster_name
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_uami.id]
  }


  default_node_pool {
    name           = "agentpool"
    vm_size        = var.vm_size
    node_count     = var.node_count
    vnet_subnet_id = azurerm_subnet.private.id
  }
  linux_profile {
    admin_username = var.username

    ssh_key {
      key_data = azapi_resource_action.ssh_public_key_gen.output.publicKey
    }
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
    service_cidr      = "10.240.0.0/16"
    dns_service_ip    = "10.240.0.10"
    outbound_type     = "loadBalancer"
  }

  # depends_on = [
  #   azurerm_subnet_route_table_association.private_assoc
  # ]

}