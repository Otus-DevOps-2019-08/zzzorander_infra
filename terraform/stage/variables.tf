variable project {
  description = "Project ID"
}
variable region {
  description = "Region"
  # Значение по умолчанию
  default = "europe-west3"
}
variable zone {
  description = "Zone"
  # Значение по умолчанию
  default = "europe-west3-a"
}
variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}

variable private_key_path {
  # Описание переменной
  description = "Path to the private key used for ssh access"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}
variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-db-base"
}

variable net_source_ranges {
  default     = ["0.0.0.0/0"]
  description = "Allowed net sources"
}
