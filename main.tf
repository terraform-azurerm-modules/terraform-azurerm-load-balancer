locals {
  resource_group_name = coalesce(var.resource_group_name, lookup(var.defaults, "resource_group_name", "unspecified"))
  location            = coalesce(var.location, var.defaults.location)
  tags                = merge(lookup(var.defaults, "tags", {}), var.tags)
  subnet_id           = var.subnet_id != "" ? var.subnet_id : lookup(var.defaults, "subnet_id", null)

  load_balancer_rules_map = {
    for rule in var.load_balancer_rules :
    join("-", [rule.protocol, rule.frontend_port, rule.backend_port]) => {
      name          = join("-", [rule.protocol, rule.frontend_port, rule.backend_port])
      protocol      = rule.protocol
      frontend_port = rule.frontend_port
      backend_port  = rule.backend_port
    }
  }
}

resource "azurerm_availability_set" "set" {
  depends_on          = [var.module_depends_on]
  name                = var.name
  resource_group_name = local.resource_group_name
  location            = local.location
  tags                = local.tags
}

resource "azurerm_lb" "set" {
  depends_on          = [var.module_depends_on]
  name                = var.name
  resource_group_name = local.resource_group_name
  location            = local.location
  tags                = local.tags

  sku = "Basic"

  frontend_ip_configuration {
    name                          = "InternalIpAddress"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = local.subnet_id
  }
}

resource "azurerm_lb_backend_address_pool" "set" {
  resource_group_name = local.resource_group_name
  loadbalancer_id     = azurerm_lb.set[var.name].id
  name                = var.name
}

resource "azurerm_lb_probe" "set" {
  for_each            = local.load_balancer_rules_map
  name                = "probe-port-${each.value.backend_port}"
  resource_group_name = local.resource_group_name
  loadbalancer_id     = azurerm_lb.set.id
  port                = each.value.backend_port // local.probe_port
}

resource "azurerm_lb_rule" "set" {
  for_each                       = local.load_balancer_rules_map
  name                           = each.value.name
  resource_group_name            = local.resource_group_name
  loadbalancer_id                = azurerm_lb.set.id
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = "InternalIpAddress"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.set.id
  probe_id                       = azurerm_lb_probe.set.id

  // Resource defaults as per https://www.terraform.io/docs/providers/azurerm/r/lb_rule.html
  enable_floating_ip      = false
  idle_timeout_in_minutes = 4
  load_distribution       = "Default" // All 5 tuples. Could  be set to  SourceIP or SourceIPProtocol.
  enable_tcp_reset        = false
  disable_outbound_snat   = false
}
