resource "yandex_compute_instance" "vm" {
  name        = "vm"
  zone        = var.default_zone
  platform_id = var.platform_standard-v3
  depends_on  = [yandex_mdb_mysql_cluster.mysql-cloud]

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
    security_group_ids = [yandex_vpc_security_group.network-1-sg.id]
  }

  metadata = {
    user-data = "${file("cloud-init.yml")}"
  }

#  lifecycle {
#    prevent_destroy = true
#    ignore_changes = [boot_disk]
#  }

  connection {
    type        = "ssh"
    user        = "user"
    private_key = file("~/.ssh/id_ed25519")
    host        = self.network_interface[0].nat_ip_address
  }

#  provisioner "remote-exec" {
#    inline = [
#      <<EOT
#        sudo mkdir app
#      EOT
#    ]
#  }

#  provisioner "file" {
#    source      = "app/"
#    destination = "/app/"
#  }

  provisioner "remote-exec" {
  inline = [
  <<EOT
  cd app/ && docker build -t app .
  EOT
    ]
  }

  provisioner "remote-exec" {
  inline = [
  <<EOT
   cd app/ && docker run --rm -p 80:80  --name my-app app
  EOT
    ]
  }

    provisioner "remote-exec" {
  inline = [
  <<EOT
   cd app/ && docker push cr.yandex/${yandex_container_registry.container-registry.id}/cloud-repository:my-app
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
    assign_public_ip = false
  }
}

resource "yandex_mdb_mysql_database" "my_db" {
  cluster_id = yandex_mdb_mysql_cluster.mysql-cloud.id
  name       = var.db-name
  depends_on  = [yandex_mdb_mysql_cluster.mysql-cloud]
}

resource "yandex_mdb_mysql_user" "my_user" {
  cluster_id = yandex_mdb_mysql_cluster.mysql-cloud.id
  name       = var.db-user
  password   = var.pass-db
  depends_on  = [yandex_mdb_mysql_cluster.mysql-cloud]

  permission {
    database_name = yandex_mdb_mysql_database.my_db.name
    roles         = ["ALL"]
  }

  connection_limits {
    max_questions_per_hour   = 10
    max_updates_per_hour     = 20
    max_connections_per_hour = 30
    max_user_connections     = 40
  }

  global_permissions = ["PROCESS"]

  authentication_plugin = "SHA256_PASSWORD"
}

resource "yandex_container_registry" "container-registry" {
  name      = "container-registry"
}

resource "yandex_container_repository" "cloud-repository" {
  name = "${yandex_container_registry.container-registry.id}/cloud-repository"
}