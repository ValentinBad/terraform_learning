#!/bin/bash
yum -y update
yum -y install httpd

myip=`curl -s http://169.254.169.254/latest/meta-data/local-ipv4`

cat <<EOF > /var/www/html/index.html
<html>
<h2>Build by Power of Terraform <font color="red"> v0.12</font></h2><br>
Owner ${instance_name}<br>

%{ for x in names ~}
Hello to ${x}<br>
%{ endfor ~}

</html>
EOF

sudo service httpd start
chkconfig httpd on
