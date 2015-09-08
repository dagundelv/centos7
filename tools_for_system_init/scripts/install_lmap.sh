#!/bin/bash
#Author:        kylin
#E-mail:        kylinlingh@foxmail.com
#blog:          http://www.cnblogs.com/kylinlin
#github:        https://github.com/Kylinlin
#Date:          2015/9/8
#version:       1.0
#Function:      Install LAMP
################################################

. /etc/rc.d/init.d/functions

function Install_Other_Tools {
    echo -e "\e[1;32mInstalling Net-tools, please wait for a while...\e[0m"
    yum install net-tools -y >> /dev/null
    echo -e "\e[1;32mInstalling command line web broswer, please wait for a while...\e[0m"
    yum install links -y >> /dev/null
}

function Install_APACHE_HTTP {
    echo -e "\e[1;32mInstalling Apache, please wait for a while...\e[0m"
    yum remove httpd -y >> /dev/null
    yum install httpd -y >> /dev/null

    echo -n -e "\e[1;34mDo you want to change the 80 port? yes or no: \e[0m"
    read CON_HTTP_PORT
    if [ $CON_HTTP_PORT == 'yes' ]; then 
        echo -n -e "\e[1;34mEnter the port number: \e[0m"
        read NEW_HTTP_PORT
        HTTP_CONF=/etc/httpd/conf/httpd.conf
        cp $HTTP_CONF $HTTP_CONF.bak

        #Configure new port for httpd
        sed -i "/^Listen/c \Listen $NEW_HTTP_PORT" $HTTP_CONF

        #Configure firewall to enable the new port
        firewall-cmd --add-service=http >> /dev/null
        firewall-cmd --permanent --add-port=$NEW_HTTP_PORT/tcp >> /dev/null
        firewall-cmd --reload >> /dev/null
        systemctl restart httpd.service >> /dev/null
    fi

    #Configure startup httpd with system boot.
    systemctl restart httpd.service >> /dev/null 
    systemctl enable httpd.service >> /dev/null

    #Check the service
    if [ `systemctl status httpd | awk -F ' ' 'NR==3 {print $2}'` == 'active' ] ; then
        action "Http service on: " /bin/true
    else
        action "Http service on: " /bin/false
    fi
    echo -e "\e[1;32mApache install finish!\e[0m"
}

function Install_PHP {
    echo -e "\e[1;32mInstalling PHP, please wait for a while...\e[0m"
    yum remove php -y >> /dev/null
    yum install php -y >> /dev/null
    
    systemctl restart httpd.service

    #Check PHP
    #echo -e "<?php\nphpinfo();\n?>" > /var/www/html/phpinfo.php
    #links http://127.0.0.1/phpinfo.php
    echo -e "\e[1;32mPHP install finish!\e[0m"
}

Install_Other_Tools
#Install_APACHE_HTTP
Install_PHP