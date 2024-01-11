# GCP Providerの設定
provider "google" {
  credentials = file("path/to/your/service-account-key.json")
  project     = "your-gcp-project-id"
  region      = "asia-northeast1"
}

# ネットワークの設定
resource "google_compute_network" "lamp_network" {
  name = "lamp-network"
}

# Apacheインスタンスの設定
resource "google_compute_instance" "apache_instance" {
  name         = "apache-instance"
  machine_type = "n1-standard-1"
  zone         = "asia-northeast1-a"
  network_interface {
    network = google_compute_network.lamp_network.self_link
  }

  # ブートディスクの設定
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  # スタートアップスクリプト
  metadata_startup_script = <<-SCRIPT
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    systemctl restart apache2
  SCRIPT
}

# MySQLインスタンスの設定
resource "google_compute_instance" "mysql_instance" {
  name         = "mysql-instance"
  machine_type = "db-n1-standard-1"
  zone         = "asia-northeast1-a"
  network_interface {
    network = google_compute_network.lamp_network.self_link
  }

  # ブートディスクの設定
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  # スタートアップスクリプト
  metadata_startup_script = <<-SCRIPT
    #!/bin/bash
    apt-get update
    debconf-set-selections <<< "mysql-server mysql-server/root_password password rootpass"
    debconf-set-selections <<< "mysql-server mysql-server/root_password_again password rootpass"
    apt-get install -y mysql-server
    systemctl restart mysql
  SCRIPT
}

# PHPインスタンスの設定
resource "google_compute_instance" "php_instance" {
  name         = "php-instance"
  machine_type = "n1-standard-1"
  zone         = "asia-northeast1-a"
  network_interface {
    network = google_compute_network.lamp_network.self_link
  }

  # ブートディスクの設定
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  # スタートアップスクリプト
  metadata_startup_script = <<-SCRIPT
    #!/bin/bash
    apt-get update
    apt-get install -y php libapache2-mod-php
    systemctl restart apache2
  SCRIPT
}

