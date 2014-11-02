sudo ln -sf /home/isucon/isucon3/final/etc/supervisord.conf /etc/supervisord.conf
sudo ln -sf /home/isucon/isucon3/final/etc/nginx/nginx.conf /etc/nginx/nginx.conf
sudo ln -sf /home/isucon/isucon3/final/etc/my.cnf /etc/my.cnf
sudo ln -sf /home/isucon/isucon3/final/etc/redis.conf /etc/redis.conf
sudo chkconfig httpd off
sudo chkconfig nginx on
