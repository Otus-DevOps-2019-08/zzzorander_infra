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
## Итоговая конфигруация:
reddit-app - сервер с нашим приложением (ruby@puma+mongodb)

## Files
install_ruby.sh - install ruby
install_mongodb.sh - install mingodb (3.2.22)
deploy.sh - deploy testapp

## Информация для Тревиса
testapp_IP = 35.198.167.169
testapp_port = 9292

