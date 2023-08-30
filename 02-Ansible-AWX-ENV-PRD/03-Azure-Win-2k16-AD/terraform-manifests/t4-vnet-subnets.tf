# Recurso de rede virtual
resource "azurerm_virtual_network" "main" {
  name                = "VNET-AD-PRD"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Recurso de sub-rede
resource "azurerm_subnet" "main" {
  name                 = "SUB-AD-PRD"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes       = ["10.0.1.0/24"]
}