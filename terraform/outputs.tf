output "load_balancer_public_ip"{
    description = "Public IP of load balancer"
    value = aws_instance.load_balancer.public_ip
}
output "bastion_public_ip" {
    description = "Pulic ip of bastion IP"
    value = var.enable_bastion ? aws_instance.bastion[0].public_ip : "Bastion is disabled"
}
output "backend_private_ips"{
    description = "Private ips of backend instances"
    value = aws_instance.backend[*].public_ip
}