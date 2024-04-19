provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-resource"
  location = "East US"
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = "example-cluster"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "example-cluster"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

# Output kubeconfig
output "kube_config" {
  value = azurerm_kubernetes_cluster.example.kube_config_raw
  sensitive = true
}

resource "null_resource" "kubectl_apply" {
  depends_on = [azurerm_kubernetes_cluster.example]

  provisioner "local-exec" {
    command = "echo '${azurerm_kubernetes_cluster.example.kube_config_raw}' > ./kubeconfig.yaml && KUBECONFIG=./kubeconfig.yaml kubectl apply -f https://raw.githubusercontent.com/ff14-advanced-market-search/temp-fe/main/kube-manifest-fe.yml"
    interpreter = ["bash", "-c"]
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}
