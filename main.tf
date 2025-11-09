resource "yandex_vpc_network" "k8s-network" {
  name = "k8s-network"
  folder_id = "${var.folder_id}"
  description = "VPC for terraform instance group"
}

resource "yandex_vpc_subnet" "k8s-subnetwork" {
  name = "k8s-subnetwork"
  zone = "ru-central1-a"
  v4_cidr_blocks = ["10.10.0.0/16"]
  network_id = "${yandex_vpc_network.k8s-network.id}"
  folder_id = "${var.folder_id}"
}

resource "yandex_iam_service_account" "k8s-sa" {
  name = "k8s-sa"
  description = "Сервисный аккаунт для управления группой ВМ k8s-compute-group."
}

resource "yandex_resourcemanager_folder_iam_member" "compute-editor" {
  folder_id = "${var.folder_id}"
  role = "compute.editor"
  member = "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
  depends_on = [yandex_iam_service_account.k8s-sa]
}

resource "yandex_resourcemanager_folder_iam_member" "vpc-admin" {
  folder_id = "${var.folder_id}"
  role = "vpc.publicAdmin"
  member = "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
  depends_on = [yandex_iam_service_account.k8s-sa]
}

resource "yandex_resourcemanager_folder_iam_member" "compute-admin" {
  folder_id = "${var.folder_id}"
  role = "compute.admin"
  member = "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
  depends_on = [yandex_iam_service_account.k8s-sa]
}

resource "yandex_vpc_security_group" "k8s-security-group" {
  name = "k8s-security-group"
  description = "Группа безопасности, которая разрешает любой трафик"
  network_id = "${yandex_vpc_network.k8s-network.id}"

  ingress {
    protocol = "ANY"
    description = "Разрешает любой входящий трафик."
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 65535
  }

  egress {
    protocol = "ANY"
    description = "Разрешает любой исходящий трафик."
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 65535
  }
}

resource "yandex_compute_instance_group" "k8s-compute-group" {
  name = "k8s-compute-group"
  # folder_id = "${var.yc_folder_id}"
  service_account_id  = "${yandex_iam_service_account.k8s-sa.id}"
  depends_on = [yandex_resourcemanager_folder_iam_member.compute-editor]
  deletion_protection = "false"

  scale_policy {
    fixed_scale {
      size = 4
    }
  }

  allocation_policy {
    zones = ["ru-central1-a"]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion = 0
  }

  instance_template {
    platform_id = "standard-v3"

    resources {
      cores  = 4
      memory = 8
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = "fd85dr1m22uur2m3cojk"
      }
    }

    network_interface {
      network_id = "${yandex_vpc_network.k8s-network.id}"
      subnet_ids = ["${yandex_vpc_subnet.k8s-subnetwork.id}"]
      security_group_ids = ["${yandex_vpc_security_group.k8s-security-group.id}"]
      nat = true
    }

    metadata = {
      # ssh-keys = "ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCj49YdMpgfHfR1HvZTAUO6d6O45sXN/jt5PalppkFfrBwVGk6RLbeRYDbLuMm0Ay/mQbme503C/8mbDMKlk2+LwPuGdiu46Ao9O8nV8oUlgk5AVwYFbkzqjTxCZfE///KZtoALng2mcQ9AsniGHlWA+9brIHlUavSxMB8IB6Nq4MGHt81L2seP66AHWkHrl19Hu7PZotnQDgW3mcBBeKMuU8hkgbMvxYBe6IFkvMkcE+2XLWFaCP6nA+RAWZOBUctG26+TRVTb3cFMz5ckUiBUp4N53V6BhPz15ZhUw4VQJvjTwQJ/urx+B4vhLSQtBOdLDHNZJ9l/3J+FHqbQDfEx2niajmsAxSRt1x9+zcJmZYysfN1QtthSopR/6kuStnbqIyHmLHQKz6gL/CMNAwVWkAxiiShk3KvcfX/00ufzdghU9mV+PWInPW45IaVxziRSGGm3E0MLdiTz7nqKOHlXoYyRndtnShYRLKEgtSh0X7uJksVRAkT6jOKz9Z9G0BnsdOkGdG0LapTAD//yQq8BXPZZ8SOloekOGRKF0ZQHB7Z/fwpl4LNfOrBdFBYYrVhMyHYKx7nj7uIOr4ABxehWbxH4k3dpHQgGvaK6nahjwzo8m3Pjz8Zhr4Fh+7v5DgLa4aLl4+gcXZzB7MF2A1WrIa5hnMF5WdCDMdbH+m5HCw== your_email@example.com"
      # ssh-keys = "ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG6L7exrkn90lGNIS06pOG3RCDOassizfnB4DV29R1Cs korvin@DESKTOP-95SH6OQ"
      user-data = file("user-data.yaml")
    }
  }
}