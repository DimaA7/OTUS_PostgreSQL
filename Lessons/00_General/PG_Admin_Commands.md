# Материалы:

[Learn SQL and Database by Examples](https://www.sqliz.com/)

[PostgreSQL 16.0 [Русский]](https://runebook.dev/ru/docs/postgresql/-index-)

# Запустить виртуальную машину:

https://console.cloud.yandex.ru/folders/b1ggmi2dmpt48jcfqocc/compute/instances

## Создать SSH ключ
ssh-keygen 
ssh-keygen -t ed25519
Ввести имя пользователя и пароль

## Подключиться используя определенный SSH ключ
ssh dima@84.201.188.155 -i C:\Users\dima-\.ssh\id_ed25519_2

## Сменить пароль ssh
ssh-keygen -p -f <Путь_к_закрытому_ключу>
ssh-keygen -p -f C:\Users\dima-\.ssh\id_ed25519_2


# Копирование публичного ключа в буфер обмена

type C:\Users\<имя_пользователя>\.ssh\<имя_ключа>.pub
Где:
- <имя_пользователя> — название вашей учетной записи Windows, например, User.
- <имя_ключа> — название ключа, например, id_ed25519 или id_rsa.
Открытый ключ будет выведен на экран. Чтобы скопировать ключ, выделите его и нажмите правую кнопку мыши. Например: ssh-ed25519 xxx/yyy

# Подключение к виртуальной машине

Для подключения к виртуальной машине в командной строке выполнить команду:

**ssh <Имя_пользователя>@51.250.68.31**



postgres по-умолчанию "postgres"

ssh <имя_пользователя>@<публичный_IP-адрес_виртуальной_машины>
Перейти под пользователя postgres: sudo su postgres
sudo -u postgres psql 

Если у вас несколько закрытых ключей, укажите нужный:

ssh -i <путь_к_ключу\имя_файла_ключа> <имя_пользователя>@<публичный_IP-адрес_виртуальной_машины>
При первом подключении к машине появится предупреждение о неизвестном хосте:

The authenticity of host '130.193.40.101 (130.193.40.101)' can't be established.
ECDSA key fingerprint is SHA256:PoaSwqxRc8g6iOXtiH7ayGHpSN0MXwUfWHkGgpLELJ8.
Are you sure you want to continue connecting (yes/no)?
Введите в командной строке yes и нажмите Enter.

См. [Подключиться к виртуальной машине Linux по SSH](https://cloud.yandex.ru/docs/compute/operations/vm-connect/ssh#creating-ssh-keys).


# PostgreSQL кластер:

15  main    5432 online postgres /var/lib/postgresql/15/main /var/log/postgresql/postgresql-15-main.log

# Подключение к PostgreSQL

sudo -u postgres psql

# Создать кластер:
sudo /usr/pgsql-15/bin/postgresql-15-setup initdb

# Запустить PostgreSQL
sudo systemctl start postgresql-12

# Enable PostgreSQL Launch on Reboot
sudo systemctl enable postgresql-12

-- посмотрим, что кластер стартовал
/usr/pgsql-12/bin/pg_ctl status
/usr/pgsql-12/bin/pg_ctl --help

# Работа с yandex облаком

### Получить список профилей YC
yc config profile list

### YC профиль test
PS C:\Users\dima-> yc config profile get test
token: y0_AgAAAAAAfsvtAATuwQAAAADg4CBSpSYKIROsT5e2yrxwcO-Dlc-YaPw
cloud-id: b1gl0du72dptm9e26vaq
folder-id: b1ggmi2dmpt48jcfqocc
compute-default-zone: ru-central1-b

### Реестр Docker
                   yc container registry create --name otus-dreg
done (1s)
id: crpsa1gldud75slpudns
folder_id: b1ggmi2dmpt48jcfqocc
name: otus-dreg
status: ACTIVE
created_at: "2023-04-23T20:19:07.966Z"

PS C:\Users\dima-> yc container registry configure-docker
docker configured to use yc --profile "test" for authenticating "cr.yandex" container registries
Credential helper is configured in 'C:\Users\dima-\.docker\config.json'
C:\Users\dima-\.docker

# Создать пльзователя, дать права
CREATE ROLE "dima" PASSWORD 'testpass' LOGIN;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "dima";
GRANT ALL PRIVILEGES ON DATABASE postgres to "dima";
select * from pg_user;
## Права на схему
GRANT USAGE ON SCHEMA public TO "dima";
GRANT CREATE ON SCHEMA public TO "dima";

[Как работать с пользователями в PostgreSQL](https://www.dmosk.ru/miniinstruktions.php?mini=postgresql-users)

# Посмотреть кластеры
pg_lsclusters

# Запустить/ остановить кластер PG:
[Stopping a postgresql instance](https://askubuntu.com/questions/642259/stopping-a-postgresql-instance)
sudo service postgresql stop
sudo systemctl stop postgresql

sudo pg_ctlcluster 15 main restart
sudo pg_ctlcluster 15 main stop
sudo pg_ctlcluster 15 main start

sudo pg_dropcluster 15 main

# Midnight Commander
Установка:
sudo apt install mc

# Конфигурация PostgreSQL postgresql.conf

postgres=# SHOW config_file;
               config_file
-----------------------------------------
 /etc/postgresql/15/main/postgresql.conf



postgres=# SHOW data_directory;
        data_directory
-------------------------------
 /var/lib/postgresql/15/main15
(1 row)


postgres@otus-db-pg-vm-2:/home/dima$ cd /etc/postgresql/15/main/
postgres@otus-db-pg-vm-2:/etc/postgresql/15/main$ nano  postgresql.conf

https://sysadminium.ru/postgresql_configuration_methods/


Монтированный диск
datapartition ab962ee0-4cd4-4406-bf0d-bce31db7c18b


SELECT * FROM pg_stat_activity;