# Настройка таймаута работы ssh клиента
[Idle SSH connection gets reset in ubuntu 20.04 WSL (Windows10)](https://superuser.com/questions/1591674/idle-ssh-connection-gets-reset-in-ubuntu-20-04-wsl-windows10)
[How to set up an ssh config-file for beginners in Windows?](https://stacktuts.com/how-to-set-up-an-ssh-config-file-for-beginners-in-windows)
[How to modify ~/.ssh folder & files in windows?](https://stackoverflow.com/questions/23064052/how-to-modify-ssh-folder-files-in-windows)
[Настройка SSH аутентификации по ключам в Windows](https://winitpro.ru/index.php/2019/11/13/autentifikaciya-po-ssh-klyucham-v-windows/)
[Setting the default ssh key location](https://stackoverflow.com/questions/84096/setting-the-default-ssh-key-location)
[Key-based authentication in OpenSSH for Windows](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_keymanagement)
[Yandex Cloud. Добавление SSH-ключей для других пользователей](https://cloud.yandex.ru/ru/docs/compute/operations/vm-connect/ssh#vm-authorized-keys)
[Использование встроенного SSH клиента в Windows 10](https://winitpro.ru/index.php/2020/01/22/vstroennyj-ssh-klient-windows/)
[Памятка пользователям ssh](https://habr.com/ru/articles/122445/)
[Магия SSH](https://habr.com/ru/articles/331348/)
[SSH ТУННЕЛЬ ► Линуксовые Фишечки #19](https://www.youtube.com/watch?v=pxXbj9dZMAM&t=511s)
[SSH Туннели на практике](https://www.youtube.com/watch?v=GBx3KEcuKFA)

## Создать SSH ключ

Перейти в папку .ssh пользователя
cd %HOMEDRIVE%%HOMEPATH%

ssh-keygen 
ssh-keygen -t ed25519
Ввести имя пользователя и пароль

Ключ генерируется в папке, в которой я нахожусь. Даже когда указано, что он должен быть в .ssh / id_rsa.
Ключ создается по умолчанию в файле, ~/.ssh/id_rsa.pub если вы просто нажимаете Enter, не указывая ему пользовательского имени. Если вы укажете любое другое имя для ключа без абсолютного пути, это создаст ключ относительно текущей рабочей папки.

Поэтому, чтобы создать ключ с вашим пользовательским именем в пользовательском расположении, вы должны указать полный путь к желаемому местоположению.


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


# Подключение к ВМПодключение к ВМ Yandex Cloud

Убедитесь, что учетная запись Windows обладает правами на чтение файлов в папке с ключами.

Для подключения к ВМ в командной строке выполните команду:

ssh <имя_пользователя>@<публичный_IP-адрес_ВМ>
Где <имя_пользователя> — имя учетной записи пользователя ВМ.

Если у вас несколько закрытых ключей, укажите нужный:

ssh -i <путь_к_ключу\имя_файла_ключа> <имя_пользователя>@<публичный_IP-адрес_ВМ>
При первом подключении к ВМ появится предупреждение о неизвестном хосте:

The authenticity of host '130.193.40.101 (130.193.40.101)' can't be established.
ECDSA key fingerprint is SHA256:PoaSwqxRc8g6iOXtiH7ayGHpSN0MXwUfWHkGgpLELJ8.
Are you sure you want to continue connecting (yes/no)?
Введите в командной строке yes и нажмите Enter.

# Добавить другие публичные SSH-ключи к вашей учётной записи в виртуальной машине можно через файл ~/.ssh/authorized_keys.

Для этого:
Скопируйте содержимое нового публичного ключа, например ~/.ssh/id_another.pub.
Подключитесь к ВМ по SSH и откройте файл с авторизованными ключами.
nano ~/.ssh/authorized_keys
Вставьте с новой строки скопированный ключ и сохраните изменения комбинацией клавиш Ctrl + O. Закройте файл комбинацией Ctrl + X.
Не отключаясь от ВМ, проверьте возможность подключения с добавленным ключом в другом окне Терминала.


# SSH туннели
  [Магия SSH](https://habr.com/ru/articles/331348/)

    Отображение всех подключений и портов прослушивания
        $ netstat -plutn

        Активные подключения
            netstat -a
            Имя    Локальный адрес        Внешний адрес          Состояние
            TCP    0.0.0.0:135            activation:0           LISTENING

        $sudo lsof -i -s -n -P


Опция -L позволяет локальные обращения (Local) направлять на удалённый сервер.
Опция -R позволяет перенаправлять с удалённого (Remote) сервера порт на свой (локальный).
 Опция ssh -A пробрасывает авторизацию на удалённый сервер.



 Пиг порта через PowerShell
    > Test-NetConnection 51.250.6.192 -p 5438

 Проброс порта
    ssh  -L 9000:localhost:9000 dima@51.250.6.192