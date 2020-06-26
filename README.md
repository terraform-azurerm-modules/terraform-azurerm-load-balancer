# terraform-azurerm-set

## Description

This Terraform module creates a "set", ready for VMs to be created. Resources created:

* application security group (always)
* availability set (bool)
* load balancer (bool)
* app gateway backend pool (bool)

> This is a WORK IN PROGRESS and will definitely change. Support is yet to be added for both basic load balancer creation and association with App Gateway backend pools.

## Example

> CLEAN UP THE EXAMPLE TO BE A FULL STANDALONE CONFIG

```terraform
locals {
  defaults = {
    module_depends_on    = [ azurerm_resource_rg ]
    resource_group_name  = azurerm_resource_group.rg.name
    location             = azurerm_resource_group.rg.location
}

resource "azurerm_resource_group" "rg" {
  name                = "set-example"
  location            = "West Europe"
  tags                 = {
      owner = "Richard Cheney",
      dept  = "Azure Citadel"
  }

}

module "set_example" {
  source        = "https://github.com/terraform-azurerm-modules/terraform-azurerm-set"
  defaults      = local.defaults
  name          = "set-example"
  load_balancer = true
}
```
