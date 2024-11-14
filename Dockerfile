FROM wordpress:latest

RUN apt-get update && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*


RUN mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql

###                      Make sure to crate secret. Password will be exposed                 ###
ENV MYSQL_DATABASE=wordpress
ENV MYSQL_USER=wpuser
ENV MYSQL_PASSWORD=wppassword
ENV MYSQL_ROOT_PASSWORD=rootpassword


ENV WORDPRESS_DB_HOST=172.17.0.1:3306
ENV WORDPRESS_DB_NAME=${MYSQL_DATABASE}
ENV WORDPRESS_DB_USER=${MYSQL_USER}
ENV WORDPRESS_DB_PASSWORD=${MYSQL_PASSWORD}


EXPOSE 80 3306


CMD service mysql start && \
    if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then \
        echo "Initializing MySQL database..."; \
        mysql -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};" && \
        mysql -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';" && \
        mysql -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'localhost';" && \
        mysql -e "FLUSH PRIVILEGES;"; \
        echo "MySQL database initialized."; \
    fi && \
    apache2-foreground

