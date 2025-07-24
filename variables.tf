variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "count-vm" {
  type    = number
  default = 2
}

variable "platform_standard-v3" {
  type    = string
  default = "standard-v3"
}

variable "cores" {
  type        = number
  default     = 2
}

variable "memory" {
  type        = number
  default     = 1
}

variable "core_fraction" {
  type        = number
  default     = 20
}

variable "size" {
  type        = number
  default     = 20
}

variable "type" {
  type        = string
  default     = "network-hdd"
}