# создайте виртуальную машину c Ubuntu 20.04/22.04 LTS в GCE/ЯО/Virtual Box/докере
# поставьте на нее PostgreSQL 15 через sudo apt
# проверьте что кластер запущен через sudo -u postgres pg_lsclusters

dima-a7@otus:~$ pg_lsclusters
Ver Cluster Port Status Owner    Data directory              Log file
15  main    5432 down   postgres /var/lib/postgresql/15/main /var/log/postgresql/postgresql-15-main.log
dima-a7@otus:~$ sudo pg_ctlcluster 15 main start
dima-a7@otus:~$ pg_lsclusters
Ver Cluster Port Status Owner    Data directory              Log file
15  main    5432 online postgres /var/lib/postgresql/15/main /var/log/postgresql/postgresql-15-main.log
dima-a7@otus:~$

# зайдите из под пользователя postgres в psql и сделайте произвольную таблицу с произвольным содержимым

       Name        |  Owner   | Encoding |   Collate   |    Ctype    | ICU Locale | Locale Provider |   Access privileges
-------------------+----------+----------+-------------+-------------+------------+-----------------+------------------------
 postgres          | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |            | libc            | =Tc/postgres          +
                   |          |          |             |             |            |                 | postgres=CTc/postgres +
                   |          |          |             |             |            |                 | "dima-a7"=CTc/postgres
 readme_to_recover | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |            | libc            |
 template0         | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |            | libc            | =c/postgres           +
                   |          |          |             |             |            |                 | postgres=CTc/postgres
 template1         | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |            | libc            | =c/postgres           +
                   |          |          |             |             |            |                 | postgres=CTc/postgres
(4 rows)

postgres=# \c postgres
You are now connected to database "postgres" as user "postgres".

## Создаем БД и таблицы

postgres=# create table test(c1 text);
postgres=# insert into test values('1');

postgres=# \dt
        List of relations
 Schema | Name | Type  |  Owner
--------+------+-------+----------
 public | test | table | postgres
(1 row)


# остановите postgres например через sudo -u postgres pg_ctlcluster 15 main stop
создайте новый диск к ВМ размером 10GB
добавьте свеже-созданный диск к виртуальной машине - надо зайти в режим ее редактирования и дальше выбрать пункт attach existing disk


# проинициализируйте диск согласно инструкции и подмонтировать файловую систему, только не забывайте менять имя диска на актуальное, в вашем случае это скорее всего будет /dev/sdb - https://www.digitalocean.com/community/tutorials/how-to-partition-and-format-storage-devices-in-linux


## Найден нераспознанный диск
dima-a7@otus:~$ sudo parted -l | grep Error
Error: /dev/vdb: unrecognised disk label

## У диска нет id
dima-a7@otus:~$ lsblk
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
loop0    7:0    0  63.4M  1 loop /snap/core20/1974
loop1    7:1    0  63.5M  1 loop /snap/core20/2015
loop2    7:2    0  79.9M  1 loop /snap/lxd/22923
loop3    7:3    0 111.9M  1 loop /snap/lxd/24322
loop4    7:4    0  53.3M  1 loop /snap/snapd/19457
loop5    7:5    0  40.9M  1 loop /snap/snapd/20290
vda    252:0    0    20G  0 disk
├─vda1 252:1    0     1M  0 part
└─vda2 252:2    0    20G  0 part /
vdb    252:16   0    10G  0 disk

## Выбор стандарта GPT
dima-a7@otus:~$ sudo parted /dev/vdb mklabel gpt
Information: You may need to update /etc/fstab.

## Создание логического диска
dima-a7@otus:~$ sudo parted -a opt /dev/vdb mkpart primary ext4 0% 100%
Information: You may need to update /etc/fstab.

## Раздел создан
dima-a7@otus:~$ lsblk
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
loop0    7:0    0  63.4M  1 loop /snap/core20/1974
loop1    7:1    0  63.5M  1 loop /snap/core20/2015
loop2    7:2    0  79.9M  1 loop /snap/lxd/22923
loop3    7:3    0 111.9M  1 loop /snap/lxd/24322
loop4    7:4    0  53.3M  1 loop /snap/snapd/19457
loop5    7:5    0  40.9M  1 loop /snap/snapd/20290
vda    252:0    0    20G  0 disk
├─vda1 252:1    0     1M  0 part
└─vda2 252:2    0    20G  0 part /
vdb    252:16   0    10G  0 disk
└─vdb1 252:17   0    10G  0 part

## Форматирование диска
dima-a7@otus:~$ sudo mkfs.ext4 -L datapartition /dev/vdb1
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 2620928 4k blocks and 655360 inodes
Filesystem UUID: ab962ee0-4cd4-4406-bf0d-bce31db7c18b
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done

## ID диска
dima-a7@otus:~$ sudo lsblk -o NAME,FSTYPE,LABEL,UUID,MOUNTPOINT
NAME   FSTYPE   LABEL         UUID                                 MOUNTPOINT
loop0  squashfs                                                    /snap/core20/1974
loop1  squashfs                                                    /snap/core20/2015
loop2  squashfs                                                    /snap/lxd/22923
loop3  squashfs                                                    /snap/lxd/24322
loop4  squashfs                                                    /snap/snapd/19457
loop5  squashfs                                                    /snap/snapd/20290
vda
├─vda1
└─vda2 ext4                   82aeea96-6d42-49e6-85d5-9071d3c9b6aa /
vdb
└─vdb1 ext4     datapartition ab962ee0-4cd4-4406-bf0d-bce31db7c18b

## Создание папки точки монтирования
sudo mkdir -p /mnt/data

## Монтирование диска
dima-a7@otus:~$ sudo mount -o defaults /dev/vdb1 /mnt/data

dima-a7@otus:~$ sudo lsblk -o NAME,FSTYPE,LABEL,UUID,MOUNTPOINT
NAME   FSTYPE   LABEL         UUID                                 MOUNTPOINT
loop0  squashfs                                                    /snap/core20/1974
loop1  squashfs                                                    /snap/core20/2015
loop2  squashfs                                                    /snap/lxd/22923
loop3  squashfs                                                    /snap/lxd/24322
loop4  squashfs                                                    /snap/snapd/19457
loop5  squashfs                                                    /snap/snapd/20290
vda
├─vda1
└─vda2 ext4                   82aeea96-6d42-49e6-85d5-9071d3c9b6aa /
vdb
└─vdb1 ext4     datapartition ab962ee0-4cd4-4406-bf0d-bce31db7c18b /mnt/data

## Тест монтирования
dima-a7@otus:~$ df -h -x tmpfs
Filesystem      Size  Used Avail Use% Mounted on
/dev/vda2        20G  5.6G   14G  30% /
/dev/vdb1       9.8G   24K  9.3G   1% /mnt/data

dima-a7@otus:~$ echo "success" | sudo tee /mnt/data/test_file
success

dima-a7@otus:~$ sudo rm /mnt/data/test_file




# перезагрузите инстанс и убедитесь, что диск остается примонтированным (если не так смотрим в сторону fstab)

## Перезагрузка
dima-a7@otus:~$ sudo pg_ctlcluster 15 main restart

## Диск остался примонтирован
dima-a7@otus:~$ sudo lsblk -o NAME,FSTYPE,LABEL,UUID,MOUNTPOINT
NAME   FSTYPE   LABEL         UUID                                 MOUNTPOINT
loop0  squashfs                                                    /snap/core20/1974
loop1  squashfs                                                    /snap/core20/2015
loop2  squashfs                                                    /snap/lxd/22923
loop3  squashfs                                                    /snap/lxd/24322
loop4  squashfs                                                    /snap/snapd/19457
loop5  squashfs                                                    /snap/snapd/20290
vda
├─vda1
└─vda2 ext4                   82aeea96-6d42-49e6-85d5-9071d3c9b6aa /
vdb
└─vdb1 ext4     datapartition ab962ee0-4cd4-4406-bf0d-bce31db7c18b /mnt/data

# сделайте пользователя postgres владельцем /mnt/data - a/chown -R postgres:postgres /mnt/data
dima-a7@otus:~$ sudo chown -R postgres:postgres /mnt/data

# перенесите содержимое /var/lib/postgres/15 в /mnt/data - mv /var/lib/postgresql/15/mnt/data
dima-a7@otus:~$ mv /var/lib/postgresql/15 /mnt/data
mv: cannot move '/var/lib/postgresql/15' to '/mnt/data/15': Permission denied
dima-a7@otus:~$ sudo mv /var/lib/postgresql/15 /mnt/data

# попытайтесь запустить кластер - sudo -u postgres pg_ctlcluster 15 main start

dima-a7@otus:~$ sudo pg_ctlcluster 15 main start
Error: /var/lib/postgresql/15/main is not accessible or does not exist

dima-a7@otus:~$ sudo -u postgres psql
could not change directory to "/home/dima-a7": Permission denied
psql: error: connection to server on socket "/var/run/postgresql/.s.PGSQL.5432" failed: No such file or directory
        Is the server running locally and accepting connections on that socket?

# напишите получилось или нет и почему

Не получилось, т.к. все данные кластера перенесены в другое место

# задание: найти конфигурационный параметр в файлах раположенных в /etc/postgresql/15/main который надо поменять и поменяйте его

По умолчанию значение для data_directory выставлено на /var/lib/postgresql/10/main в файле /etc/postgresql/10/main/postgresql.conf. Его нужно отредактировать, чтобы указать новый каталог:
sudo nano /etc/postgresql/10/main/postgresql.conf

# напишите что и почему поменяли

В postgresql.conf поменял:
 data_directory = '/mnt/data/15/main'

# попытайтесь запустить кластер - sudo -u postgres pg_ctlcluster 15 main start
# напишите получилось или нет и почему

Не получилось, т.к. перед перемещением папки и изменением конфига не останавливали кластер. 


dima-a7@otus:~$ sudo -u postgres pg_ctlcluster 15 main start
Warning: the cluster will not be running as a systemd service. Consider using systemctl:
  sudo systemctl start postgresql@15-main

dima-a7@otus:~$ sudo systemctl start postgresql@15-main
Job for postgresql@15-main.service failed because the service did not take the steps required by its unit configuration.
See "systemctl status postgresql@15-main.service" and "journalctl -xeu postgresql@15-main.service" for details.

dima-a7@otus:~$ pg_lsclusters
Ver Cluster Port Status Owner    Data directory    Log file
15  main    5432 down   postgres /mnt/data/15/main /var/log/postgresql/postgresql-15-main.log

dima-a7@otus:~$ systemctl status postgresql@15-main.service
× postgresql@15-main.service - PostgreSQL Cluster 15-main
     Loaded: loaded (/lib/systemd/system/postgresql@.service; enabled-runtime; vendor preset: enabled)
     Active: failed (Result: protocol) since Fri 2023-11-10 19:50:03 UTC; 1min 17s ago
    Process: 3549 ExecStart=/usr/bin/pg_ctlcluster --skip-systemctl-redirect 15-main start (code=exited, status=2)
        CPU: 37ms

Нужно использовать команды остановки и запуска сервиса кластера:

sudo systemctl stop postgresql@15-main
sudo systemctl start postgresql@15-main
или:
sudo systemctl start postgresql
sudo systemctl stop postgresql


# зайдите через psql и проверьте содержимое ранее созданной таблицы

Получилось:

postgres=# \dt
        List of relations
 Schema | Name | Type  |  Owner
--------+------+-------+----------
 public | test | table | postgres
(1 row)

postgres=# select * from test;
 c1
----
 1
(1 row)

# задание со звездочкой *: не удаляя существующий инстанс ВМ сделайте новый, поставьте на его PostgreSQL, удалите файлы с данными из /var/lib/postgres, перемонтируйте внешний диск который сделали ранее от первой виртуальной машины ко второй и запустите PostgreSQL на второй машине так чтобы он работал с данными на внешнем диске, расскажите как вы это сделали и что в итоге получилось.

1. На другой ВМ (ВМ2) устанавил Postgres 15
    * sudo apt update && sudo apt upgrade -y && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && sudo apt-get update && sudo apt-get -y install postgresql-15

2. Останавил кластера postgres на ВМ1 и ВМ2
    
    sudo -u postgres pg_ctlcluster 15 main stop
    или
    sudo systemctl stop postgresql@15-main

3. Удалил каталог с данными на ВМ2
    sudo rm -rf /var/lib/postgres/

4. Перемонтировал в YC внешний диск который сделали ранее от первой виртуальной машины ко второй
   остановить обе ВМ на YC
   отключить диск от ВМ1 
      sudo umount -f /mnt/data # принудительно
      sudo umount -l  /mnt/data # лениво
   Подключить к ВМ2 

5. На ВМ2 проверить наличие монтированного диска

dima-a7@otus:~$ sudo lsblk -o NAME,FSTYPE,LABEL,UUID,MOUNTPOINT
NAME   FSTYPE   LABEL         UUID                                 MOUNTPOINT
loop0  squashfs                                                    /snap/core20/1974
loop1  squashfs                                                    /snap/core20/2015
loop2  squashfs                                                    /snap/lxd/22923
loop3  squashfs                                                    /snap/lxd/24322
loop4  squashfs                                                    /snap/snapd/19457
loop5  squashfs                                                    /snap/snapd/20290
vda
├─vda1
└─vda2 ext4                   82aeea96-6d42-49e6-85d5-9071d3c9b6aa /
vdb
└─vdb1 ext4     datapartition ab962ee0-4cd4-4406-bf0d-bce31db7c18b

6. Создание папки точки монтирования
sudo mkdir -p /mnt/data

7. Монтирование диска
dima-a7@otus:~$ sudo mount -o defaults /dev/vdb1 /mnt/data

8. Изменить data_directory в /etc/postgresql/15/main/postgresql.conf на ВМ2
    sudo nano /etc/postgresql/15/main/postgresql.conf
    data_directory = '/mnt/data/15/main'

9. Запустить кластер на ВМ2 
   sudo systemctl start postgresql@15-main 

10. Зайти под postgres
dima-a7@otus:~$ sudo -u postgres psql
could not change directory to "/home/dima-a7": Permission denied
psql (15.5 (Ubuntu 15.5-1.pgdg22.04+1))
Type "help" for help.

11. Сделать запросы
postgres=# \dt

        List of relations
 Schema | Name | Type  |  Owner
--------+------+-------+----------
 public | test | table | postgres
(1 row)

postgres=# select * from test;
 c1
----
 1
(1 row)