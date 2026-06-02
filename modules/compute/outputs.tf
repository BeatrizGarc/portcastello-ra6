output "dc_ip_privada" {
  description = "IP privada del DC (configurar como DNS en los clientes)"
  value       = aws_instance.dc.private_ip
}

output "linux_server_ip_privada" {
  description = "IP privada del servidor Linux"
  value       = aws_instance.linux_server.private_ip
}

output "win_cli_public_ip" {
  description = "IP pública EIP del cliente Windows"
  value       = aws_eip.win_cli.public_ip
}

output "linux_cli_public_ip" {
  description = "IP pública EIP del cliente Linux"
  value       = aws_eip.linux_cli.public_ip
}
