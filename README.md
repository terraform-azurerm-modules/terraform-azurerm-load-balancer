# terraform-azurerm-load-balancer

## Description

This Terraform module creates a standardised load balancer and availaibility set.

## Example

> CLEAN UP THE EXAMPLE TO BE A FULL STANDALONE CONFIG WITH A VNET & SUBNET. And add in details for variables and outputs plus the use of the defaults.

```terraform
locals {
  defaults = {
    module_depends_on    = [ azurerm_resource_rg ]
    resource_group_name  = azurerm_resource_group.rg.name
    location             = azurerm_resource_group.rg.location
    tags                 = azurerm_resource_group.rg.tags
    subnet_id            = <subnet_id>
}

resource "azurerm_resource_group" "rg" {
  name                = "lb-example"
  location            = "West Europe"
  tags                 = {
      owner = "Richard Cheney",
      dept  = "Azure Citadel"
  }

}

module "lb_example" {
  source        = "https://github.com/terraform-azurerm-modules/terraform-azurerm-local-balancer"
  defaults      = local.defaults
  name          = "lb-example"
}
```
