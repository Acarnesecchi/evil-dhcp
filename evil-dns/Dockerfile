FROM ubuntu:latest

RUN apt-get update && apt-get install -y bind9

COPY named.conf* /etc/bind/
COPY db.* /var/cache/bind/

CMD ["/usr/sbin/named", "-g", "-c", "/etc/bind/named.conf", "-u", "bind"]
