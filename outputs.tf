/*
output "availability_set_id" {
  value       = azurerm_availability_set.lb.id
}
*/

output "load_balancer_private_ip_address" {
  value = azurerm_lb.lb.frontend_ip_configuration[0].private_ip_address
}

output "load_balancer_backend_address_pool_id" {
  value = azurerm_lb_backend_address_pool.lb.id
}

/*
output "load_balancer_rules" {
  value = {
    for key, value in local.load_balancer_rules_map :
    (key) => {
      rule  = azurerm_lb_rule.lb[key]
      probe = azurerm_lb_probe.lb[key]
    }
  }
}
*/