# zzzorander_infra
zzzorander Infra repository

# cloud-bastion итоговая конфигурация:
- bastion - VPN шлюз (Pritunl)
- someinternalhost - машина без доступа в internet

# Информация для Тревиса
bastion_IP = 34.89.205.5
someinternalhost_IP = 10.156.0.4

# Подключение по ssh к someinternalhost одной командой
Можно прыгать к недоступоному снаружи серверу используюя ключ -J и список хостов-прокси через зпаятую:
`ssh -J user@host1,user@host2 user@host3`

# Подключение по ssh к someinternalhost с использованием ssh_config
Прописываем в `~/.ssh/config`:
```Host someinternalhost
	Hostname 10.156.0.4
	ProxyJump appuser@34.89.205.5
	User appuser
```
Теперь можно подключиться к someinternalhost введя команду:
`ssh someinternalhost`
