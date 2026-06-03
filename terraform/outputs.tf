output "ip_dc_privada" {
  description = "IP privada del DC — usar como DNS en los clientes"
  value       = module.compute.dc_ip_privada
}

output "ip_publica_win_cli" {
  description = "IP pública EIP del cliente Windows (RDP)"
  value       = module.compute.win_cli_public_ip
}

output "ip_publica_linux_cli" {
  description = "IP pública EIP del cliente Linux (SSH)"
  value       = module.compute.linux_cli_public_ip
}

output "comando_rdp" {
  description = "Comando directo para conectar por RDP"
  value       = "mstsc /v:${module.compute.win_cli_public_ip}"
}

output "comando_ssh" {
  description = "Comando directo para conectar por SSH"
  value       = "ssh -i labsuser.pem ubuntu@${module.compute.linux_cli_public_ip}"
}
