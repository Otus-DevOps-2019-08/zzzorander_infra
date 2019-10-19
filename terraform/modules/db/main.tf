resource "google_compute_instance" "db" {
  name         = "reddit-db"
  machine_type = "g1-small"
  zone         = var.zone
  tags         = ["reddit-db"]
  boot_disk {
    initialize_params {
      image = var.db_disk_image
    }
  }
  network_interface {
    network = "default"
    access_config {}
  }
  metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo sed -i -e 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/g' /etc/mongod.conf",
      "sudo systemctl restart mongod"
    ]
  }
  connection {
    type        = "ssh"
    user        = "appuser"
    private_key = file(var.private_key_path)
    host        = self.network_interface[0].access_config[0].nat_ip
  }
}

resource "google_compute_firewall" "firewall_mongo" {
  name    = "allow-mongo-default"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = [var.db_port]
  }
  target_tags = ["reddit-db"]
  source_tags = ["reddit-app"]
}
