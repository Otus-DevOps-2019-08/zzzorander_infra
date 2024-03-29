# zzzorander_infra
zzzorander Infra repository

# cloud-bastion
## Итоговая конфигурация:
- bastion - VPN шлюз (Pritunl)
- someinternalhost - машина без доступа в internet

## Информация для Тревиса
bastion_IP = 34.89.205.5
someinternalhost_IP = 10.156.0.4

## Дополнительные задания
### Подключение по ssh к someinternalhost одной командой
Можно "прыгать" к недоступному снаружи серверу используя ключ -J и список хостов-прокси через запятую:
`ssh -J user@host1,user@host2 user@host3`

### Подключение по ssh к someinternalhost с использованием ssh_config
Прописываем в `~/.ssh/config`:
```Host someinternalhost
	Hostname 10.156.0.4
	ProxyJump appuser@34.89.205.5
	User appuser
```
Теперь можно подключиться к someinternalhost введя команду:
`ssh someinternalhost`

# cloud-testapp
## Итоговая конфигурация:
- reddit-app - сервер с нашим приложением (ruby@puma+mongodb)

## Files
- install_ruby.sh - install ruby
- install_mongodb.sh - install mongodb (3.2.22)
- deploy.sh - deploy testapp
- testapp-startup.sh - testapp deploy script

## Информация для Тревиса
testapp_IP = 35.210.42.191
testapp_port = 9292

## Дополнительные задания
### startup-script
Все операции одной командой
```
gcloud compute instances create reddit-app \
--boot-disk-size=10GB \
--image-family ubuntu-1604-lts \
--image-project=ubuntu-os-cloud \
--machine-type=g1-small \
--tags puma-server \
--restart-on-failure \
--zone europe-west1-c \
--metadata startup-script='#!/bin/sh
sudo su -
wget -qO - https://www.mongodb.org/static/pgp/server-3.2.asc | sudo apt-key add -
cat <<EOF > /etc/apt/sources.list.d/mongodb-org-3.2.list
deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse
EOF
apt update
apt install -y ruby-full ruby-bundler build-essential mongodb-org
systemctl start mongod
systemctl enable mongod
cd /home/appuser
git clone -b monolith https://github.com/express42/reddit.git
cd reddit
bundle install
puma -d
'
```
### Создать правило firewall
`gcloud compute firewall-rules create default-puma-server --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:9292 --source-ranges=0.0.0.0/0 --target-tags=puma-server`

# packer-base
## Итоговая конфигурация:
- reddit-app - сервер с нашим приложением (ruby@puma+mongodb)

## Files
- packer/scripts/install_ruby.sh - ставим ruby и зависимости
- packer/scripts/install_mongodb.sh - ставим mongodb (3.2.22)
- packer/files/deploy.sh - ставим testapp
- packer/files/puma-service.sh - регистрируем puma в systemd
- config-scripts/create-reddit-vm.sh - разворачиваем в gcp наш сервер из подготовленного образа.

## Краткое описание
- создан файл-описание для создания базового образа reddit-base
- создан образ reddit-base
- добавлены переменные для чувствительных данных, создан .gitignore
- создан файл-описание для создание "запеченого" образа reddit-full из reddit-base
- создан образ reddit-full
- создан скрипт для запуска виртуальной машины с использованием образа reddit-full

# terraform-1
## HW
- Описана инфраструктура в `main.tf`
- Описаны переменные в `variables.tf`
- Переменным задано значение через `terraform.tfvars`
- Заданны переменные для "google_compute_instance" "app" "Zone"
- Все файлы отформатированы командой `terraform fmt`
- Создан `terraform.tfvars.example`
## HW*
- Добавил ssh ключ `appuser_web` через веб-консоль.
- Добавлены ключи ssh через разные конструкции:
```
resource "google_compute_project_metadata" "ssh-keys" {
  metadata = {
  ssh-keys = <<EOF
    appuser1:${file(var.public_key_path)}
    appuser2:${file(var.public_key_path)}
  EOF
  }
}
```
В итоге ключ `appuser_web` пропал из списка ключей, и вместо него появились два ключа `appuser1` и `appuser2`
- Далее я использовал следующую конструкцию:
```
resource "google_compute_project_metadata_item" "ssh-keys1" {
  key = "ssh-keys"
  value = "appuser1:${file(var.public_key_path)}"
}

resource "google_compute_project_metadata_item" "ssh-keys2" {
  key = "ssh-keys"
  value = "appuser2:${file(var.public_key_path)}"
}
```
После применения данной конструкции в веб-консоли остался только ключ `appuser2`
- Так же попробовал конструкцию:
```
resource "google_compute_project_metadata_item" "ssh-keys1" {
  key = "ssh-keys"
  value = <<EOF
    appuser1:${file(var.public_key_path)}
    appuser2:${file(var.public_key_path)}
  EOF
}
```
Получил опять два ключа в списке - `appuser1` + `appuser2`

# terraform-2
## HW
- Освоил terraform import - для импорта ресурса его нужно объявить в конфигурации, и только после этого его можно будет импортировать.
- Вынес базу данных на отдельный инстанс (итого у нас теперь две VM)
- Разбил конфигураци terraform на модули (app, db)
- Добавил модуль "vpc" и поиграл правилами firewall
- Добавил и настроил два окружения "stage"&"prod" 
- Применил модуль из реестра для создания bucket

## HW*
- Добавил в stage и prod описание backend ссылающийся на bucket созданный в HW, разделил их префиксами (для prod префикс - "prod", для stage - "stage" ).
- Проверил доступность state из разных расположений при отсутствии локальных state-файлов.
- Проверил блокировки при попытке одновременного изменения одной конфигурации из разных мест - работает!

## HW**
- Добавил provisioner в модули app и db. 
- Прописал переменную окружения в /etc/environment на app (автоматически при развертывании)
- Переназначил bindIp (0.0.0.0) в mongod.conf
- Получил непонятную мне проблему - app пишет ошибку соединения с db, хотя я при этом из консоли на app спокойно подключаюсь к db командой `$ mongo $DATABASE_URL` ¯\\\_(ツ)_/¯

# Ansible-1
## HW
- Установил Ansible (поставил глобально `sudo pip install -r requirements.txt`)
- Сделал ветку `ansible-1`
- Cоздал папку `ansible`
- Создал и заполнил файл `inventory`
- Создал и заполнил файл `ansible.cfg`
- Создал и заполнил файл `inventory.yml`
- Создал и заполнил плейбук `clone.yml` при заполнении поймал несколько странных глюков с YAML, но копипаст из гиста спас положение.
- При первом запуске плейбука у нас ничего не произошло, поскольку репозиторий в папке reddit был актуальным и гит просто проверил его валидность, о чем нам было выведено сообщение: `appserver  : ok=2    changed=0`
- При втором запуске, после удаления папки `reddit` из домашней директории пользователя `appuser` указанная в плейбуке папка была не обнаружена, и было выполнено действие `git clone` и папка появилась, о чем нам сообщил `ansible-playbook` выдав в конце задачи отчет: `appserver  : ok=2    changed=1`

## HW*
- Написал простейший скрипт на python3, который симулирует логику динамического инвентори. 

# Ansible-2
## HW
- Рассмотрел вариант использования тегов в playbook, сделал playbook "все в одном" с разделением тегами. По пути посмотрел как работать с шаблонами Jinja2, понял как работают handlers
- Заменил теги в сценарии на группы хостов, к которым разные части сценария применяются. Дописал сценарий для деплоя самостоятельно.
- Поделил наш playbook на несколько более мелких, чтобы на каждую роль был свой playbook + общий деплой, переименовал старые playbook'и. Сделал playbook site.yml который делает import_playbook для всех playbook'ов, учавствующих в развертывани.
- Переписал provision для packer. Для этого создали два playbook `packer_app.yml`  и `packer_db.yml` и изменили соответствующим образом `db.json` и `app.json`, после чего запаковал новые образы.
- Проверил работоспособность приложения - все в порядке.

# Ansible-3
## HW
- Создал роли, перенес в структуры ролей переменные, задачи и обработчики
- Все активные плейбуки перенес в папку `playbooks`
- Все устаревшие плейбуки от предыдущих заданий перенес в `old`
- Создал два окружения и заполнил для них переменные и инвентори. По умолчанию теперь используется окружение `stage`
- Добавил комьюнити роль с nginx, добавил требуемые переменные в каждое окружение.
- Создал плейбук для добавления пользователей, и зашифровал его с помощью `ansible-vault` файл с ключем положил в отдельную папку вне репозитория.
## HW*
- Настроил динамические инвентори для двух окружений, по умолчанию используется `stage` 
