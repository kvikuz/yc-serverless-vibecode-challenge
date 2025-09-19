#!/bin/bash

set -e

# Установка переменных окружения
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)

# Проверка наличия необходимых переменных окружения
if [[ -z "$YC_TOKEN" || -z "$YC_CLOUD_ID" || -z "$YC_FOLDER_ID" ]]; then
    echo "Ошибка: Не удалось получить значения переменных окружения YC_TOKEN, YC_CLOUD_ID или YC_FOLDER_ID"
    exit 1
fi

# Инициализация Terraform
echo "Инициализация Terraform..."
terraform init

# Применение конфигурации только для реестра
echo "Создание реестра контейнеров..."
terraform apply -auto-approve \
    -var="yc_token=$YC_TOKEN" \
    -var="yc_cloud_id=$YC_CLOUD_ID" \
    -var="yc_folder_id=$YC_FOLDER_ID" \
    -target=yandex_container_registry.main \
    -target=yandex_iam_service_account.registry-account \
    -target=yandex_resourcemanager_folder_iam_member.sa-editor \
    -target=yandex_container_registry_iam_member.admin

# Получение ID реестра из состояния Terraform
REGISTRY_ID=$(terraform output -raw registry_id)
if [[ -z "$REGISTRY_ID" ]]; then
    echo "Ошибка: Не удалось получить ID реестра из состояния Terraform"
    exit 1
fi

echo "Используем реестр с ID: $REGISTRY_ID"

# Аутентификация в реестре Yandex Cloud
echo "Аутентификация в реестре Yandex Cloud..."
yc container registry configure-docker --hostname cr.yandex

# Сборка Docker образа
echo "Сборка Docker образа..."
docker build --platform linux/amd64 -t cr.yandex/$REGISTRY_ID/app-registry/nextjs-app:latest -f Dockerfile ..

# Пуш образа в реестр
echo "Загрузка образа в реестр..."
docker push cr.yandex/$REGISTRY_ID/app-registry/nextjs-app:latest

# Применение конфигурации для создания контейнера
echo "Создание serverless контейнера..."
terraform apply -auto-approve \
    -var="yc_token=$YC_TOKEN" \
    -var="yc_cloud_id=$YC_CLOUD_ID" \
    -var="yc_folder_id=$YC_FOLDER_ID"

# Получение URL контейнера
CONTAINER_URL=$(terraform output -raw container_url)
echo "Приложение доступно по адресу: $CONTAINER_URL"
