
[Сайт о Linux Losst](https://losst.pro/terminal)

## Разархивирование файла в Linux
  Установка unzip
    sudo apt install unzip
  Разархивирование В каталоге, в котором находится ZIP-файл
    /home/dima# unzip demo-big.zip -d demo_pgpro
  Распаковка в каталог
    unzip zipped_file.zip -d unzipped_directory
  Просмотр содержимого архива без распаковки
    unzip -l zipped_file.zip

  Запуск SQL файла на БД
    psql -U postgres -p5432 -d pg_part_less -f /home/dima-a7/demo_pgpro/pg_part_less.sql