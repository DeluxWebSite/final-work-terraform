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
  value = yandex_compute_instance.vm.network_interface.0.nat_ip_address
}

output "private_ip" {
  value = yandex_compute_instance.vm.network_interface.0.ip_address
}

output "permission" {
  value = data.yandex_mdb_mysql_user.my_user.permission
}

output "cluster_fqdn" {
  description = "FQDN for the mysql cluster"
  value       = "c-${yandex_mdb_mysql_cluster.mysql-cloud.id}.rw.mdb.yandexcloud.net"
}

# output "hosts_fqdns" {
#  description = "FQDNs of all cluster hosts"
#  value       = [
#    for host in yandex_mdb_mysql_cluster.mysql-cloud.host : host.fqdn
#  ]
# }

resource "local_file" "env_file" {
  filename = "${path.module}/app/.env"
  content  = <<EOT
DB_HOST=c-${yandex_mdb_mysql_cluster.mysql-cloud.id}.rw.mdb.yandexcloud.net
DB_PORT=6432
DB_USER=${yandex_mdb_mysql_user.my_user.name}
DB_PASSWORD=${yandex_mdb_mysql_user.my_user.password}
DB_NAME=${yandex_mdb_mysql_database.my_db.name}
EOT
}