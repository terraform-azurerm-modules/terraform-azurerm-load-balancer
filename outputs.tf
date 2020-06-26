output "name" {
  value = var.name
}

output "availability_set_id" {
  value = azurerm_availability_set.set.id
}

output "load_balancer_backend_pool_id" {
  value = azurerm_lb_backend_address_pool.set.id
}
