# Настройка таймаута работы ssh клиента
[Idle SSH connection gets reset in ubuntu 20.04 WSL (Windows10)](https://superuser.com/questions/1591674/idle-ssh-connection-gets-reset-in-ubuntu-20-04-wsl-windows10)
[Настройка SSH аутентификации по ключам в Windows](https://winitpro.ru/index.php/2019/11/13/autentifikaciya-po-ssh-klyucham-v-windows/)
[How to set up an ssh config-file for beginners in Windows?](https://stacktuts.com/how-to-set-up-an-ssh-config-file-for-beginners-in-windows)
[How to modify ~/.ssh folder & files in windows?](https://stackoverflow.com/questions/23064052/how-to-modify-ssh-folder-files-in-windows)


Добавить другие публичные SSH-ключи к вашей учётной записи в виртуальной машине можно через файл ~/.ssh/authorized_keys.
    Для этого:
        Скопируйте содержимое нового публичного ключа, например ~/.ssh/id_another.pub.
        Подключитесь к ВМ по SSH и откройте файл с авторизованными ключами. nano ~/.ssh/authorized_keys
        Вставьте с новой строки скопированный ключ и сохраните изменения комбинацией клавиш Ctrl + O. Закройте файл комбинацией Ctrl + X.
        Не отключаясь от ВМ, проверьте возможность подключения с добавленным ключом в другом окне Терминала.