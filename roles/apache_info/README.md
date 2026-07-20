# Роль `apache_info`

Роль устанавливает и запускает Apache, создаёт страницу с характеристиками
управляемого хоста и проверяет её доступность. Поддерживаются Debian/Ubuntu и
RHEL-подобные системы.

## Переменные

- `apache_manage_firewall` — управлять правилом для HTTP, по умолчанию `true`;
- `apache_http_port` — HTTP-порт, по умолчанию `80`.

## Пример

```yaml
- hosts: managed
  become: true
  gather_facts: true
  roles:
    - role: apache_info
```
