#!/bin/sh

minikube stop
minikube delete

# Start docker
minikube start --driver=docker
# Enable dashboard
minikube addons enable dashboard

# Installing Metallb
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/metallb.yaml
kubectl get secret -n metallb-system memberlist
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

# Get external IP
export EXTERNAL_IP=`minikube ip`
sed -i s/'172.17.0.3'/$EXTERNAL_IP/ srcs/ftps/ftps.yaml
sed -i s/'172.17.0.3'/$EXTERNAL_IP/ srcs/grafana/grafana.yaml
sed -i s/'172.17.0.3'/$EXTERNAL_IP/ srcs/influxdb/influxdb.yaml
sed -i s/'172.17.0.3'/$EXTERNAL_IP/ srcs/mysql/mysql.yaml
sed -i s/'172.17.0.3'/$EXTERNAL_IP/ srcs/nginx/nginx.yaml
sed -i s/'172.17.0.3'/$EXTERNAL_IP/ srcs/phpmyadmin/phpmyadmin.yaml
sed -i s/'172.17.0.3'/$EXTERNAL_IP/ srcs/wordpress/wordpress.yaml
sed -i s/'172.17.0.3'/$EXTERNAL_IP/ srcs/metallb_configmap.yaml

# Apply secrets
WP_DB_NAME=wp_database; WP_DB_USER=admin; WP_DB_PASSWD=password; WP_DB_TABLE_PREFIX=wp_db_;
MYSQL_ADMIN=admin; MYSQL_ADMIN_PASSWD=password;

kubectl create secret generic mysql-secret \
    --from-literal=wordpress-db-name=${WP_DB_NAME} \
    --from-literal=wordpress-mysql-db-user=${WP_DB_USER} \
    --from-literal=wordpress-mysql-db-passwd=${WP_DB_PASSWD} \
    --from-literal=wordpress-db-table-prefix=${WP_DB_TABLE_PREFIX} \
    --from-literal=mysql-admin=${MYSQL_ADMIN} \
    --from-literal=mysql-admin-passwd=${MYSQL_ADMIN_PASSWD}

FTP_USER=admin; FTP_PASSWD=password;

kubectl create secret generic ftps-secret \
    --from-literal=ftp-user=${FTP_USER} \
    --from-literal=ftp-passwd=${FTP_PASSWD} \

WP_DB_HOST=mysql;
kubectl create secret generic wp-db-configmap \
    --from-literal=wp-db-host=${WP_DB_HOST} \

# Ensure all shell script copied are executable
chmod +x srcs/*/*.sh

# Building images
eval $(minikube docker-env)
docker build -t my_mysql        srcs/mysql      --network=host
docker build -t my_wordpress    srcs/wordpress  --network=host
docker build -t my_phpmyadmin   srcs/phpmyadmin --network=host
docker build -t my_nginx        srcs/nginx      --network=host
docker build -t my_ftps         srcs/ftps       --network=host
docker build -t my_grafana      srcs/grafana    --network=host
docker build -t my_influxdb     srcs/influxdb   --network=host

kubectl apply -f srcs/metallb_configmap.yaml

# Apply deployments and services
kubectl apply -f srcs/mysql/mysql.yaml
kubectl apply -f srcs/wordpress/wordpress.yaml
kubectl apply -f srcs/phpmyadmin/phpmyadmin.yaml
kubectl apply -f srcs/nginx/nginx.yaml
kubectl apply -f srcs/ftps/ftps.yaml
kubectl apply -f srcs/grafana/grafana.yaml
kubectl apply -f srcs/influxdb/influxdb.yaml

# Start dashboard
minikube dashboard &

# kubectl explain pod => get info about pods and yml config
# kubectl explain deploy => get info about deployments
# curl localhost pour verif nginx ok
# test persistence => kubectl get pods => kubectl delete pod ftps-5587b86b84-r68sb (par ex), si après new get pods ftps redémarre : ok
# kubectl get pv (pour connaitre les volumes persistants : pour ftps, influx, mysql)