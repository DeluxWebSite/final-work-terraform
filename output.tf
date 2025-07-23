output "vpc_network_id" {
  value = yandex_vpc_network.network-1.id
}

output "subnet_zone" {
  value = yandex_vpc_subnet.subnet-1.zone
}

output "security_group_id" {
  value = yandex_vpc_security_group.network-1-sg.id
}

output "public_ip" {
   value = yandex_compute_instance.vm[*].network_interface.0.nat_ip_address
}

output "private_ip" {
   value = yandex_compute_instance.vm[*].network_interface.0.ip_address
}