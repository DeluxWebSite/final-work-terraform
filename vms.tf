data "yandex_compute_image" "img" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "vm" {
  count       = var.count-vm
  name        = "vm-${count.index}"
  zone        = var.default_zone
  platform_id = var.platform_standard-v3
  depends_on  = [yandex_mdb_postgresql_cluster.mysql-cloud]

  resources {
    cores         = var.cores # Минимальное значение vCPU = 2. ccылка: https://cloud.yandex.ru/docs/compute/concepts/performance-levels
    memory        = var.memory
    core_fraction = var.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.img.id
      type     = var.type
      size     = var.size
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-1.id
    nat                = true
#   ip_address         = "192.168.1.11"
    security_group_ids = [yandex_vpc_security_group.network-1-sg.id]
  }

  metadata = {
    user-data = "${file("cloud-init.yml")}"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [boot_disk]
  }

  connection {
    type        = "ssh"
    user        = "user"
#    private_key = file("~/.ssh/id_ed25519")
    host        = self.network_interface[0].nat_ip_address
  }

  provisioner "remote-exec" {
  inline = [
<<EOT
sudo docker run -d -p 0.0.0.0:80:3000 \
  -e DB_TYPE=postgres \
  -e DB_NAME=${var.db-name} \
  -e DB_HOST=${yandex_mdb_mysql_cluster.mysql-cloud.host.0.fqdn} \
  -e DB_PORT=6432 \
  -e DB_USER=${var.db-user} \
  -e DB_PASS=${var.pass-db} \
  ghcr.io/requarks/wiki:2.5
EOT
    ]
  }
}

resource "yandex_mdb_mysql_cluster" "mysql-cloud" {
  name        = "mysql-cloud"
  environment = "PRESTABLE"
  network_id  = yandex_vpc_network.network-1.id
  version     = "8.0"
  depends_on  = [yandex_vpc_network.network-1, yandex_vpc_subnet.subnet-1]

  resources {
    resource_preset_id = "s2.micro"
    disk_type_id       = "network-ssd"
    disk_size          = 16
  }

  mysql_config = {
    max_connections               = 100
    innodb_print_all_deadlocks    = true
  }

  host {
    zone      = var.default_zone
    subnet_id = yandex_vpc_subnet.subnet-1.id
#    assign_public_ip = false
  }
}

resource "yandex_mdb_mysql_database" "my_db" {
  cluster_id = yandex_mdb_mysql_cluster.mysql-cloud.id
  name       = var.db-name
  owner      = yandex_mdb_postgresql_user.my_user.name
  lc_collate = "en_US.UTF-8"
  lc_type    = "en_US.UTF-8"
  depends_on  = [yandex_mdb_postgresql_cluster.mysql-cloud]
}

resource "yandex_mdb_mysql_user" "my_user" {
  cluster_id = yandex_mdb_mysql_cluster.mysql-cloud.id
  name       = var.db-user
  password   = var.pass-db
  depends_on  = [yandex_mdb_postgresql_cluster.mysql-cloud]
}
