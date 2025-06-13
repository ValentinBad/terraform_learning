#!/bin/bash

# Оновлення пакетів
apt update -y
apt install -y apache2 curl

# Отримання приватної IP-адреси
myip=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Створення веб-сторінки
cat <<EOF > /var/www/html/index.html
<html>
<body bgcolor="black">
<h2><font color="gold">Build by Power of Terraform <font color="red"> v0.12</font></h2><br><p>
<font color="green">Server PrivateIP: <font color="aqua">$myip<br><br>
<font color="magenta">
<b>Version 4.0</b>
</body>
</html>
EOF

# Запуск Apache
systemctl start apache2
systemctl enable apache2
