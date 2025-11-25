packer {
  required_version = ">= 1.10.0"
  required_plugins {
    qemu = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "k8s_version" {
  type    = string
  default = "1.31.3"
}

variable "nvidia_driver" {
  type    = string
  default = "550.127.05"
}

variable "encryption_passphrase" {
  type    = string
  sensitive = true
}

source "qemu" "encrypted-k8s" {
  iso_url      = "https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso"
  iso_checksum = "sha256:8f0b191d3c1f7e1b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f60718293a4b5c6d"  # Update checksum as needed
  vm_name      = "ubuntu-k8s-encrypted-${var.k8s_version}"
  disk_size    = "50000"  # 50GB
  format       = "qcow2"
  accelerator  = "kvm"
  ssh_username = "ubuntu"
  ssh_password = "ubuntu"
  ssh_timeout  = "30m"
  memory       = 8192
  cpus         = 4
  boot_wait    = "8s"
  http_directory = "http"
  boot_command = [
    "<esc><wait>",
    "linux /casper/vmlinuz --- autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
    "<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter>"
  ]
}

build {
  sources = ["source.qemu.encrypted-k8s"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update && sudo apt-get upgrade -y",
      "sudo apt-get install -y cryptsetup-bin lvm2 ansible curl gnupg ca-certificates"
    ]
  }

  provisioner "ansible-local" {
    playbook_file   = "../ansible/encrypt-and-harden.yml"
    extra_arguments = ["--extra-vars", "k8s_version=${var.k8s_version} nvidia_driver=${var.nvidia_driver} encryption_passphrase=${var.encryption_passphrase}"]
  }

  provisioner "shell" {
    inline = ["sudo sync && sudo rm -rf /tmp/* /var/tmp/*"]
  }
}
