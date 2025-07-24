resource "yandex_vpc_network" "network-1" {
  name = "network-1"
  description = "Network"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name = "subnet-1"
  description = "Subnet"
  zone = var.default_zone
  network_id = yandex_vpc_network.network-1.id
#  network_id = "${yandex_vpc_network.network-1.id}"
  v4_cidr_blocks = var.default_cidr
}

resource "yandex_vpc_security_group" "network-1-sg" {
  name       = "network-1-sg"
  network_id = yandex_vpc_network.network-1.id

  ingress {
    protocol       = "TCP"
    description    = "Allow SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "Allow HTTP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "Allow HTTP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  ingress {
    protocol       = "ICMP"
    description    = "Allow Echo request - ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }

  egress {
    protocol       = "ANY"
    description    = "To internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}
