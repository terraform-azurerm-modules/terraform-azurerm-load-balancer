# terraform-azurerm-load-balancer

## Description

This Terraform module creates a standardised load balancer and availability set.

Refer to the variables.tf for a full list of the possible options and default values.

Note that if the load_balancer rules list is not specified then it will default to a NAT rule passing 443 (HTTPS) through to the 443 port on the backend.

## Example 1

```terraform
resource "azurerm_resource_group" "example" {
  name     = "lb-example"
  location = "West Europe"
  tags = {
    owner = "Richard Cheney",
    dept  = "Azure Citadel"
  }
}

resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tags                = azurerm_resource_group.example.tags
  address_space       = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.0.0/26"]
}

module "example-lb" {
  source = "https://github.com/terraform-azurerm-modules/terraform-azurerm-load-balancer"

  name                = "lb-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tags                = azurerm_resource_group.example.tags
  subnet_id           = azurerm_subnet.example.id

  load_balancer_rules = [{
      protocol      = "Tcp",
      frontend_port = 80,
      backend_port  = 8080
    },
    {
      protocol      = "Tcp",
      frontend_port = 443,
      backend_port  = 8443
    }
  ]
}

output "example_load_balancer_ip_address" {
  value = module.example-lb.load_balancer_private_ip_address
}

output "example_availability_set_id" {
  value = module.example-lb.availability_set_id
}

output "example_load_balancer_backend_address_pool_id" {
  value = module.example-lb.load_balancer_backend_address_pool_id
}
```

## Example 2

The real benefit of the module is that you can define a set of defaults and leverage that if you are creating many availability sets and load balancers.

See the example-hub and example-spoke repositories for fuller examples, including how the outputs are used by the terraform-azurerm-linux-vm and terraform-azurerm-linux-vmss modules.

```terraform

<snip>

locals {
  defaults = {
    resource_group_name = azurerm_resource_group.example.name
    location            = azurerm_resource_group.example.location
    tags                = azurerm_resource_group.example.tags
    subnet_id           = azurerm_subnet.example.id
  }
}

module "example-lb1" {
  source   = "https://github.com/terraform-azurerm-modules/terraform-azurerm-local-balancer"
  defaults = locals.defaults
  name     = "lb-example1"
}

module "example-lb2" {
  source   = "https://github.com/terraform-azurerm-modules/terraform-azurerm-local-balancer"
  defaults = locals.defaults
  name     = "lb-example2"

  load_balancer_rules = [
    { protocol      = "Tcp", frontend_port = 80,  backend_port  = 8080 },
    { protocol      = "Tcp", frontend_port = 443, backend_port  = 8443 }
  ]
}

module "example-lb3" {
  source    = "https://github.com/terraform-azurerm-modules/terraform-azurerm-local-balancer"
  defaults  = locals.defaults
  name      = "lb-example3"
  subnet_id = azurerm_subnet.alternative.id
}
```
