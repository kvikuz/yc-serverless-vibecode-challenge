# Описание задачи

Задание, которое необходимо решить в данном проекте:
1. Сгенерировать при помощи AI-ассистента веб-приложение на языке [Typescript](https://www.typescriptlang.org) и фреймворке [Next.JS](https://nextjs.org) по заданному промту (примеры заданий-промтов лежат в каталоге [promts](promts)).
2. Собрать сгенерированное приложение в docker-образ и развернуть в виде контейнера в Yandex Cloud в сервисе [Serverless Containers](https://yandex.cloud/en/services/serverless-containers).

# Описание окружения

- Работу необходимо проводить из установленного VSCode и плагина Roo Code (на своем оборудовании можно использовать и других агентов и IDE, например Cursor и тд.). 
- Так же должна быть установлена YC CLI, настроен и активирован профиль для работы с облаком.
- Для сборки и деплоя необходимы будут [Docker](https://www.docker.com)([Podman](https://podman.io)) и [Terraform](https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-quickstart#install-terraform). 

# Описание проекта

- Данный проект представляет собой каркас веб-приложения на языке [Typescript](https://www.typescriptlang.org) и фреймворке [Next.JS](https://nextjs.org).
- Общее описание проекта, зависимости и настройки js/ts находятся в файлах [package.json](package.json) и [tsconfig.json](package.json).
- Код приложения находится в каталоге [src](src).
- Скрипт деплоя, Dockerfile и terraform-рецепты накодятся в каталоге [deploy](deploy). Для сборки и деплоя необходимо выполнить команду ```cd deploy && bash deploy.sh```. В большинстве случаев агент сам предложит выполнить эту команду.
- В каталоге [.roo](.roo) находится [файл](.roo/rules/00-general-rules.md) с системным промтом для агента, он описывает общие рекомендации, которым следует модель при дизайне приложения и генерации кода. Для генерации кода по заданию в Roo Code можно использовать как режим Code, так и режим Orchestrator. Последний дает более качественный результат, но работает дольше.
