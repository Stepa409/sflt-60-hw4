# Домашнее задание к занятию «Ansible. Часть 2» — Andrey Stepanov

Решение практического задания с самопроверкой по теме «Ansible. Часть 2».
Во всех плейбуках и в роли используются специализированные модули Ansible;
модули `shell` и `command` не используются.

## Подготовка

1. Скопируйте проект в Linux-VM. Текущий [`inventory.ini`](inventory.ini)
   настроен для запуска плейбуков непосредственно внутри неё через local
   connection. Если Ansible запускается с другого компьютера, замените строку
   `localhost` адресом и SSH-пользователем VM.
2. Убедитесь, что запускающий пользователь может выполнять `sudo`.
3. Установите необходимые коллекции:

   ```bash
   ansible-galaxy collection install -r collections/requirements.yml
   ```

4. Проверьте доступность управляемого хоста:

   ```bash
   ansible managed -m ansible.builtin.ping
   ```

## Задание 1

Подготовлены три отдельных плейбука:

1. [`playbooks/01_archive.yml`](playbooks/01_archive.yml) создаёт каталоги,
   скачивает архив Apache Kafka модулем `get_url` и распаковывает его модулем
   `unarchive`.
2. [`playbooks/02_tuned.yml`](playbooks/02_tuned.yml) устанавливает пакет
   `tuned`, запускает сервис и включает его автозапуск.
3. [`playbooks/03_motd.yml`](playbooks/03_motd.yml) записывает в `/etc/motd`
   приветствие из переменной `motd_message`.

Команды запуска:

```bash
ansible-playbook playbooks/01_archive.yml
ansible-playbook playbooks/02_tuned.yml
ansible-playbook playbooks/03_motd.yml
```

## Задание 2

Плейбук [`playbooks/04_motd_facts.yml`](playbooks/04_motd_facts.yml) собирает
Ansible facts и формирует приветствие с hostname и IP-адресом управляемого
хоста, а также пожеланием хорошего дня системному администратору.

```bash
ansible-playbook playbooks/04_motd_facts.yml
```

После выполнения содержимое проверяется отдельным плейбуком без использования
модулей `shell` и `command`:

```bash
ansible-playbook playbooks/06_verify.yml
```

## Задание 3

Создана роль [`roles/apache_info`](roles/apache_info), которая:

- устанавливает Apache (`apache2` для Debian/Ubuntu, `httpd` для RHEL-подобных
  систем);
- создаёт `index.html` из Jinja2-шаблона с CPU, RAM, первым диском и IP-адресом;
- размещает отдельный конфигурационный файл Apache;
- открывает HTTP-порт через UFW или firewalld;
- запускает Apache и включает его автозапуск;
- перезапускает Apache обработчиком только при изменении его конфигурации;
- проверяет код ответа 200 модулем `uri`.

Запуск роли:

```bash
ansible-playbook playbooks/05_apache_role.yml
```

Архив роли для прикрепления к заданию создаётся командой:

```bash
tar -czf artifacts/apache_info_role.tar.gz -C roles apache_info
```

## Проверка идемпотентности

Каждый плейбук следует запустить дважды. Во втором запуске ожидается
`changed=0` (если системное состояние между запусками не менялось):

```bash
ansible-playbook playbooks/05_apache_role.yml
ansible-playbook playbooks/05_apache_role.yml
```

## Вывод выполнения

Фактический вывод сохранён на целевом Linux-хосте без подмены результата и
добавлен в каталог [`artifacts`](artifacts):

| Плейбук | Первый запуск | Повторный запуск |
| --- | --- | --- |
| Архив | [`changed=4, failed=0`](artifacts/01_archive_first.log) | [`changed=0, failed=0`](artifacts/01_archive_idempotency.log) |
| tuned | [`changed=1, failed=0`](artifacts/02_tuned_first.log) | [`changed=0, failed=0`](artifacts/02_tuned_idempotency.log) |
| MOTD из переменной | [`changed=1, failed=0`](artifacts/03_motd_first.log) | [`changed=0, failed=0`](artifacts/03_motd_idempotency.log) |
| MOTD из facts | [`changed=1, failed=0`](artifacts/04_motd_facts_first.log) | [`changed=0, failed=0`](artifacts/04_motd_facts_idempotency.log) |
| Роль Apache | [`changed=5, failed=0`](artifacts/05_apache_role_first.log) | [`changed=0, failed=0`](artifacts/05_apache_role_idempotency.log) |

Архив роли: [`artifacts/apache_info_role.tar.gz`](artifacts/apache_info_role.tar.gz),
SHA-256: `53fb2c95ee82c8a7030ca2d7f6371e19d968d131269b0d83ed703d9d09dfa722`.

## Итоговая проверка

Плейбук [`playbooks/06_verify.yml`](playbooks/06_verify.yml) без изменения
системы проверяет наличие распакованного архива, содержимое MOTD, состояние
служб `tuned` и Apache, а также ответ HTTP 200.

```bash
ansible-playbook playbooks/06_verify.yml
```

Фактический результат: [`ok=7, changed=0, failed=0`](artifacts/06_verify.log).

Проверено на Ubuntu 24.04.3 ARM64 с Ansible Core 2.16.3. Сформированная
веб-страница показывает следующие facts управляемого хоста:

- CPU: `2 vCPU`;
- RAM: `3894 МБ`;
- первый HDD: `sda — 64.00 GB`;
- IP-адрес: `10.211.55.4`.

Службы `tuned` и `apache2` находятся в состояниях `active` и `enabled`.
Правило UFW для TCP/80 добавлено; сам UFW не включался принудительно, поскольку
до выполнения задания firewall на учебной VM был неактивен.
