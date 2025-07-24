data "yandex_compute_image" "img" {
  family = "ubuntu-2204-lts"
}

data "yandex_lb_network_load_balancer" "my_nlb" {
  network_load_balancer_id = "my-network-load-balancer"
}

data "yandex_lb_target_group" "my_tg" {
  target_group_id = "my-target-group-id"
}

data "yandex_mdb_mysql_cluster" "my_cluster" {
  name = "mysql-cloud"
}

data "yandex_mdb_mysql_user" "my_user" {
  cluster_id = yandex_mdb_mysql_cluster.mysql-cloud.id
  name = var.db-user
}

data "yandex_container_repository" "repo-1" {
  name = yandex_container_repository.cloud-repository.name
}