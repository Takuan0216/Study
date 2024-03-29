# GCP Providerの設定
provider "google" {
  project     = var.project_id
  region      = "asia-northeast1"
}

#プロジェクトIDの変数定義
variable "project_id" {
	type = string
	default = ""
}

#VPC作成
resource "google_compute_network" "vpc_network" {
  name                    = "my-custom-mode-network"
  auto_create_subnetworks = false
  mtu                     = 1460
}

#サブネット作成
resource "google_compute_subnetwork" "default" {
  name          = "my-custom-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "asia-northeast1"
  network       = google_compute_network.vpc_network.id
}

# Rocky OSのGCE作成
resource "google_compute_instance" "default" {
  name         = "rockey-nginx-vm"
  machine_type = "e2-medium"
  zone         = "asia-northeast1-a"
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = "rocky-linux-cloud/rocky-linux-8"
    }
  }

  # nginxインストール・起動
  metadata_startup_script = "sudo yum update; sudo yum -y install nginx; sudo systemctl start nginx; sudo systemctl enable nginx"

  network_interface {
    subnetwork = google_compute_subnetwork.default.id

    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}

# SSH接続を許可するファイアウォール作成
resource "google_compute_firewall" "ssh" {
  name = "allow-ssh"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

# HTTP接続を許可するファイアウォール作成
resource "google_compute_firewall" "nginx" {
  name    = "nginx-firewall"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
}

# 接続用のURL出力
output "Web-server-URL" {
 value = join("",["http://",google_compute_instance.default.network_interface.0.access_config.0.nat_ip])
}
