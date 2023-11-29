
Материалы для изучения:
* [Основы Git - Запись изменений в репозиторий](https://git-scm.com/book/ru/v2/Основы-Git-Запись-изменений-в-репозиторий)
* [30 команд Git, необходимых для освоения интерфейса командной строки Git](https://habr.com/ru/companies/ruvds/articles/599929/)


# Перейти в репозиторий
PS C:\> cd GitRepo
PS C:\GitRepo> cd 05_Autovacuum
PS C:\GitRepo\05_Autovacuum> 

# Добавить репозиторий (папку) в Git к проекту GitHub
PS C:\GitRepo\2_Postgre_SQL_Intro> git remote add origin https://github.com/DimaA7/OTUS_PostgreSQL
 https://github.com/DimaA7/2_Postgre_SQL_Intro.git
error: remote origin already exists.

# Инициализация репозитория
git init

# Добавление файлов в репозиторий
PS C:\GitRepo\2_Postgre_SQL_Intro> git add 01_DBMS_History.jpg

# Посмотреть статус что изменено
PS C:\GitRepo\2_Postgre_SQL_Intro> git status
On branch main
nothing to commit, working tree clean

# Добавить в индекс Git:
PS C:\GitRepo\2_RDBMS> git add Readme.md
PS C:\GitRepo\OTUS_PostgreSQL> git add HomeWork

# Закомитить в Git
git commit -m "комментарий к коммиту"
PS C:\GitRepo\2_Postgre_SQL_Intro> git commit -m "наполнение Readme.md, добавление рисунка"
[master (root-commit) 7039ac8] наполнение Readme.md, добавление рисунка
 create mode 100644 01_DBMS_History.jpg

git remote add 05_Autovacuum https://github.com/DimaA7/05_Autovacuum

# Просмотр удаленного репозитория
Для того чтобы просмотреть список названий удаленных репозиториев, с которыми работаем:
git remote
git remote show <remote> 

# Загрузить в GitHub
git push -u origin master
PS C:\GitRepo\2_Postgre_SQL_Intro> git push -u origin main
Everything up-to-date

PS C:\GitRepo\OTUS_PostgreSQL> git push -u OTUS_PostgreSQL master      
Enumerating objects: 8, done.
Counting objects: 100% (8/8), done.
Delta compression using up to 4 threads
Compressing objects: 100% (7/7), done.
Writing objects: 100% (8/8), 399.33 KiB | 13.31 MiB/s, done.
Total 8 (delta 0), reused 0 (delta 0), pack-reused 0
remote: 
remote: Create a pull request for 'master' on GitHub by visiting:
remote:      https://github.com/DimaA7/OTUS_PostgreSQL/pull/new/master
remote:
To https://github.com/DimaA7/OTUS_PostgreSQL
 * [new branch]      master -> master
branch 'master' set up to track 'OTUS_PostgreSQL/master'.


# Статьи
[Основы Git - Работа с удалёнными репозиториями](https://git-scm.com/book/ru/v2/Основы-Git-Работа-с-удалёнными-репозиториями)
[Ежедневная работа с Git](https://habr.com/ru/articles/174467/)
[Команда git remote add origin для работы с удаленными репозиториями](https://selectel.ru/blog/tutorials/git-remote-add-origin-or-how-to-work-with-remote-repositories/)




# Есть репозиторий на гитхаб, я скачал файлы методом кнопки download вместо того что бы клонировать. И за этого файлы никак не связанны с тем репозиторием. Как сделать что бы файлы на моем пк подключились к тому репозиторию? ( Изменение сделал в локальных файлах, поэтому клонировать тот с гитхаба не вариант )
Это делается командой git remote add, но делать её можно только на существующем репозитории, так что вам понадобится ещё и git init. Потом вам понадобится получить из репозитория коммиты командой git fetch и сделать git reset чтобы вносить свои изменения не с нуля, а начиная с головы репозитория.

git init
git remote add origin url_репозитория
git fetch origin
git reset --mixed origin/master
git add измененные файлы
git commit -m "комментарий к коммиту"
git push -u origin master