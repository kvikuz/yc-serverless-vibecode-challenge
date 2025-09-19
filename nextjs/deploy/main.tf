terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

variable "yc_token" {
  description = "Yandex Cloud API token"
  type        = string
}

variable "yc_cloud_id" {
  description = "Yandex Cloud cloud ID"
  type        = string
}

variable "yc_folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = "ru-central1-a"
}

resource "yandex_container_registry" "main" {
  name = "app-registry"
}

resource "yandex_iam_service_account" "registry-account" {
  name        = "registry-account"
  description = "account for registry"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.yc_folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.registry-account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "registry-admin" {
  folder_id = var.yc_folder_id
  role      = "container-registry.admin"
  member    = "serviceAccount:${yandex_iam_service_account.registry-account.id}"
}

resource "yandex_serverless_container" "app-container" {
  name               = "app-container"
  service_account_id = yandex_iam_service_account.registry-account.id
  image {
    url = "cr.yandex/${yandex_container_registry.main.id}/${yandex_container_registry.main.name}/nextjs-app:latest"
  }
  memory = 1024
  cores  = 1
  concurrency = 4
  execution_timeout = "60s"
}

resource "yandex_serverless_container_iam_binding" "app-container-iam" {
  container_id = "${yandex_serverless_container.app-container.id}"
  role         = "serverless.containers.invoker"

  members = [
    "system:allUsers",
  ]
}

output "registry_id" {
  value = yandex_container_registry.main.id
}

output "container_url" {
  value = yandex_serverless_container.app-container.url
}