
resource "google_compute_instance" "instance" {
  name                      = "vm-instance-name"
  machine_type              = "f1-micro"
  zone                      = "europe-west1-b"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params{
      image = "debian-cloud/debian-8"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  tags = ["foo", "bar"]

}
