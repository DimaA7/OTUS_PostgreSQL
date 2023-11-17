# 2. SQL и реляционные СУБД. Введение в PostgreSQL. Домашняя работа.


## Цели занятия
объяснить основу реляционной модели данных;
объяснить назначение языка SQL и его основные конструкции;
иметь представление об основных реляционных СУБД;
рассмотреть разницу в уровнях изоляции транзакций

## Краткое содержание
реляционная модель и SQL;
OLTP, ACID, MVCC, ARIES;
уровни изоляции транзакций;
современные РСУБД;
введение в PostgreSQL и практика.

## Результаты
будет говорит на одном языке с разработчиками и архитекторами БД;
создаст собственный проект в GCP;
проверит работу различных уровней изоляции транзакций в своем проекте

## Преподаватель
Евгений Аристов

## Компетенции
владение базовыми навыками работы в SQL
- основа реляционной модели данных
- назначение языка SQL
## Дата и время
6 апреля, четверг в 20:00
Длительность занятия: 90 минут

## Домашнее задание
Работа с уровнями изоляции транзакции в PostgreSQL

## Цель:
научиться работать с Google Cloud Platform на уровне Google Compute Engine (IaaS)
научиться управлять уровнем изолции транзации в PostgreSQL и понимать особенность работы уровней read commited и repeatable read

## Описание/Пошаговая инструкция выполнения домашнего задания:
создать новый проект в Google Cloud Platform, Яндекс облако или на любых ВМ, докере
далее создать инстанс виртуальной машины с дефолтными параметрами
добавить свой ssh ключ в metadata ВМ
зайти удаленным ssh (первая сессия), не забывайте про ssh-add
поставить PostgreSQL
зайти вторым ssh (вторая сессия)
запустить везде psql из под пользователя postgres
выключить auto commit
сделать в первой сессии новую таблицу и наполнить ее данными create table persons(id serial, first_name text, second_name text); insert into persons(first_name, second_name) values('ivan', 'ivanov'); insert into persons(first_name, second_name) values('petr', 'petrov'); commit;
посмотреть текущий уровень изоляции: show transaction isolation level
начать новую транзакцию в обоих сессиях с дефолтным (не меняя) уровнем изоляции
в первой сессии добавить новую запись insert into persons(first_name, second_name) values('sergey', 'sergeev');
сделать select * from persons во второй сессии
видите ли вы новую запись и если да то почему? **Во второй сессии не видим новую запись, т.к. в первой сессии транзакция не закомичена, а на уровне read committed не разрешено Грязное» чтение (dirty read)**
завершить первую транзакцию - commit;
сделать select * from persons во второй сессии
видите ли вы новую запись и если да то почему? **Да,вижу, т.к. установлен уровень изоляции read committed на котором допускается Неповторяющееся чтение (non-repeatable read)**
завершите транзакцию во второй сессии


начать новые но уже repeatable read транзации - set transaction isolation level repeatable read;
в первой сессии добавить новую запись insert into persons(first_name, second_name) values('sveta', 'svetova');
сделать select * from persons во второй сессии
видите ли вы новую запись и если да то почему? **Нет не вижу, т.к. транзакция в первой сессии не закомичена, а на уровне repeatable read не разрешено Грязное» чтение (dirty read)**
завершить первую транзакцию - commit;
сделать select * from persons во второй сессии
видите ли вы новую запись и если да то почему? **Нет не вижу, т.к. на уровне Repeatable Read в PG не допускается Неповторяющееся чтение (non-repeatable read).**
завершить вторую транзакцию
сделать select * from persons во второй сессии
видите ли вы новую запись и если да то почему? **Да вижу, т.к. закомичена транзакция на изменение в первой сессии и закомичена первая транзакция чтения во второй сессии. Данные запрашиваются уже во второй транзакции второй сессии.**


ДЗ сдаем в виде миниотчета в markdown в гите

## Критерии оценки:
Критерии оценивания:
Выполнение ДЗ: 10 баллов
плюс 2 балла за красивое решение
минус 2 балла за рабочее решение, и недостатки указанные преподавателем не устранены

## Рекомендуем сдать до: 09.04.2023

# Материалы

- [Инструкция Личный кабинет студента](https://docs.google.com/presentation/d/17fs6RI_Aqc58eMbmvK6Ww-DYXL-U2O4lbG6LaHvkmjc/edit?usp=sharing)
- [Как попасть на занятие в Zoom?](https://docs.google.com/presentation/d/1I43BcOz4BgNZcovmA3ypz7jB_583nb8ADXb5PmA2ELg/edit?usp=sharing)
- [PostgreSQL 15: Часть 1 или Коммитфест 2021-07](https://habr.com/ru/company/postgrespro/blog/572782/)
- [An Intro to Git and GitHub for Beginners (Tutorial)](https://product.hubspot.com/blog/git-and-github-tutorial-for-beginners)
- [SmartGit – Git Client for Windows, macOS, Linux](https://www.syntevo.com/smartgit/)
- [Markdown за 5 минут](https://htmlacademy.ru/blog/articles/markdown)
- [Гайд - как правильно сформулировать цель обучения.pdf](https://cdn.otus.ru/media/private/1e/c4/Гайд___как_правильно_сформулировать_цель_обучения-301039-1ec468.pdf?hash=aB9F-N3P7SXn3juFm-_TBg&expires=1680744099)
- [Don't Do This - PostgreSQL wiki](https://wiki.postgresql.org/wiki/Don't_Do_This)
- [Lesser Known PostgreSQL Features](https://hakibenita.com/postgresql-unknown-features?ref=refind)
- [Как добавить изображение в Markdown](https://denshub.com/ru/hugo-post-insert-image/)
- yandex_cloud.mp4
- yandex_cloud.md
- 01 PG История.pdf
- POSTGRE-DBA-2023-03_Реляционные базы, история и место в современном мире.mp4

<image src="/2_Postgre_SQL_Intro/01_DBMS_History.jpg" alt="Описание картинки">