FROM ubuntu:latest

RUN apt-get update && apt-get install -y isc-dhcp-server

COPY dhcpd.conf /etc/dhcp/dhcpd.conf

RUN mkdir -p /var/lib/dhcp && \
    mkdir -p /var/run && \
    touch /var/lib/dhcp/dhcpd.leases

CMD ["dhcpd", "-f", "-d", "--no-pid"]
