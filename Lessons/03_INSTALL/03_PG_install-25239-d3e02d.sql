-- развернем ВМ postgres в GCE
--image-family=ubuntu-2204-lts
gcloud beta compute --project=celtic-house-266612 instances create postgres --zone=us-central1-a --machine-type=e2-medium --subnet=default --network-tier=PREMIUM --maintenance-policy=MIGRATE --service-account=933982307116-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --image-family=ubuntu-2204-lts --image-project=ubuntu-os-cloud --boot-disk-size=10GB --boot-disk-type=pd-ssd --boot-disk-device-name=postgres --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any

gcloud compute ssh postgres

-- установим 15 Постгрес
sudo apt update && sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y -q && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt -y install postgresql-15



-- pg_updatecluster
-- попробуем создать кластер на предыдущей версии
pg_createcluster 13 main 


sudo DEBIAN_FRONTEND=noninteractive apt install -y postgresql-13

pg_lsclusters

pg_upgradecluster 13 main

-- что произошло?

man pg_upgradecluster

-- справочник по командам линукс
-- https://explainshell.com/

-- зададим с новым каталогом
sudo pg_upgradecluster 13 main upgrade13
-- опять не получилось( имен не могут совпадать для одинаковых верси ПГ

-- переименуем старый кластер
sudo pg_renamecluster 13 main main13

pg_lsclusters

sudo -u postgres psql -p 5433

-- зададим пароль
CREATE ROLE testpass PASSWORD 'testpass' LOGIN;
CREATE DATABASE otus;
exit

sudo -u postgres psql -p 5433 -U testpass -h localhost -d postgres -W

CREATE DATABASE otus2;

-- заапдейтим версию кластера
sudo pg_upgradecluster 13 main13

pg_lsclusters

-- обратите внимание, что старый кластер остался. Давайте удалим его
sudo pg_dropcluster 13 main13

-- зададим маску подсети, откуда разрешен доступ
sudo cat /etc/postgresql/15/main13/pg_hba.conf

-- scram-sha-256
-- for all users on localhost
sudo nano /etc/postgresql/15/main13/pg_hba.conf

sudo pg_ctlcluster 15 main13 reload
-- error
sudo -u postgres psql -p 5433 -U testpass -h localhost -d postgres -W

-- md5
-- for all users on localhost
sudo nano /etc/postgresql/15/main13/pg_hba.conf

sudo pg_ctlcluster 15 main13 reload
-- ok
sudo -u postgres psql -p 5433 -U testpass -h localhost -d postgres -W

ALTER USER testpass PASSWORD 'testpass';
exit

-- change back to scram-sha-256
sudo nano /etc/postgresql/15/main13/pg_hba.conf

sudo pg_ctlcluster 15 main13 reload
sudo -u postgres psql -p 5433 -U testpass -h localhost -d postgres -W


-- Откроем доступ извне - на каком интерфейсе мы будем слушать подключения
sudo pg_conftool 15 main13 set listen_addresses '*'
sudo nano /etc/postgresql/15/main13/postgresql.conf
sudo nano /etc/postgresql/15/main13/pg_hba.conf
sudo pg_ctlcluster 15 main13 restart

-- с ноута
psql -p 5433 -U testpass -h 334.71.131.96 -d postgres -W
-- не пускает.. почему?

-- обратите внимание на порта
-- идем в VPC
sudo pg_ctlcluster 15 main13 stop
sudo pg_dropcluster 15 main13


--cloud sql
-- не забываем настроить какую подсеть он будет слушать
-- 9tvGLCXfuZBQbDf

psql -p 5432 -U postgres -h 34.173.148.196 -d postgres -W


-- ЯО
-- есть пример в доп.материал к лекции от Виталия Попова со списком команд
-- https://cloud.yandex.ru/docs/compute/concepts/vm-metadata
!! not  --name pg-instance \
!! --ssh-key ~/.ssh/aeugene.pub


yc compute instance create \
  --name pg-instance \
  --hostname pg-instance \
  --create-boot-disk size=15G,type=network-ssd,image-folder-id=standard-images,image-family=ubuntu-2204-lts \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --zone ru-central1-a \
  --metadata-from-file ssh-keys=/home/aeugene/.ssh/aeugene.txt

-- обратит внимание на aeugene.txt
cat aeugene.txt

yc compute instance get pg-instance
yc compute instance get --full pg-instance


ssh aeugene@62.84.127.76
ssh yc-user@62.84.127.76
ssh root@62.84.127.76
ssh ubuntu@51.250.8.2

-- если что пошло не так - серийная консоль
-- https://github.com/yandex-cloud/docs/blob/master/ru/compute/operations/serial-console/index.md

-- поставим 15 ПГ
sudo apt update && sudo apt upgrade -y -q && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && sudo apt-get update && sudo apt -y install postgresql-15

pg_lsclusters

-- с ноута
psql -h 62.84.127.76

-- почему нет доступа??

-- не открыли доступ - listener
sudo pg_conftool 15 main set listen_addresses '*'

-- не указали откуда слушаем подключения
sudo nano /etc/postgresql/15/main/pg_hba.conf
sudo pg_ctlcluster 15 main restart

-- не задали пароль otus$123
sudo -u postgres psql
\password


-- с ноута
psql -h 51.250.8.2
Password for user aeugene:

-- откуда aeugene? нам же postgres otus$123
psql -h 51.250.8.2 -U postgres

-- вуаля

yc compute instance delete pg-instance


-- docker
-- полное руководство на Хабре, кто любит поосновательнее 
-- https://habr.com/ru/post/310460/

-- уберем лишние кластера
pg_lsclusters
sudo pg_ctlcluster 15 main stop
sudo pg_dropcluster 15 main

-- поставим докер
-- https://docs.docker.com/engine/install/ubuntu/
curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh && rm get-docker.sh && sudo usermod -aG docker $USER && newgrp docker


-- 1. Создаем docker-сеть: 
sudo docker network create pg-net

-- 2. подключаем созданную сеть к контейнеру сервера Postgres:
sudo docker run --name pg-server --network pg-net -e POSTGRES_PASSWORD=postgres -d -p 5432:5432 -v /var/lib/postgres:/var/lib/postgresql/data postgres:15

-- 3. Запускаем отдельный контейнер с клиентом в общей сети с БД: 
sudo docker run -it --rm --network pg-net --name pg-client postgres:15 psql -h pg-server -U postgres

-- 4. Проверяем, что подключились через отдельный контейнер:
sudo docker ps -a

psql -h localhost -U postgres -d postgres

-- с ноута
psql -p 5432 -U postgres -h 34.31.155.220 -d postgres -W

-- подключение без открытия порта наружу
sudo docker run --name pg-server --network pg-net -e POSTGRES_PASSWORD=postgres -d -v /var/lib/postgres:/var/lib/postgresql/data postgres:15
sudo docker run -it --rm --network pg-net --name pg-client postgres:15 psql -h pg-server -U postgres


-- минимальный запуск
sudo docker run --name pg-server -p 5432:5432 -e POSTGRES_PASSWORD=postgres postgres:15



-- зайти внутрь контейнера
sudo docker exec -it pg-server bash

-- установить VIM & NANO
-- внутри контейнера ubuntu)
cat /proc/version

apt-get update
apt-get install vim nano -y

psql -U postgres

show hba_file;
show config_file;
show data_directory;

sudo docker ps

sudo docker stop

-- рестарт контейнера после смерти
docker run -d --restart unless-stopped/always



-- docker compose
sudo apt install docker-compose -y

-- используем утилиту защищенного копирования по сети
scp /mnt/d/download/docker-compose.yml aeugene@34.71.131.96:/home/aeugene/

cat docker-compose.yml

sudo docker-compose up -d

-- password - secret
sudo -u postgres psql -h localhost

-- почему нет старой БД?




sudo su
cd /var/lib/docker/volumes/aeugene_pg_project/_data
ls -la


-- удалим наш проект
gcloud compute instances delete postgres


