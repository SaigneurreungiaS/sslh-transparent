FROM alpine:3.20.3
MAINTAINER Alex <github@jumel.xyz>

ENV LISTEN_IP 0.0.0.0
ENV LISTEN_PORT 443
ENV SSH_HOST localhost
ENV SSH_PORT 22
ENV OPENVPN_HOST localhost
ENV OPENVPN_PORT 1194
ENV HTTPS_HOST localhost
ENV HTTPS_PORT 8443
ENV WIREGUARD_HOST localhost
ENV WIREGUARD_PORT 51820

RUN apk update && \
       apk add --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ sslh && \
       rm -rf /var/cache/apk/* \
       iptables -t mangle -N SSLH \
       iptables -t mangle -A OUTPUT -p tcp -o eth0 --sport 4443 -j SSLH \
       iptables -t mangle -A OUTPUT -p tcp -o eth0 --sport 1194 -j SSLH \
       iptables -t mangle -A OUTPUT -p tcp -o eth0 --sport 51820 -j SSLH \
       iptables -t mangle -A OUTPUT -p tcp -o eth0 --sport 80 -j SSLH \
       iptables -t mangle -A OUTPUT -p tcp -o eth0 --sport 22 -j SSLH \
       iptables -t mangle -A SSLH -j MARK --set-mark 0x1 \
       iptables -t mangle -A SSLH -j ACCEPT \
       ip rule add fwmark 0x1 lookup 100 \
       ip route add local 0.0.0.0/0 dev lo table 100 \
       ip6tables -t mangle -N SSLH \
       ip6tables -t mangle -A OUTPUT -p tcp -o eth0 --sport 4443 -j SSLH \
       ip6tables -t mangle -A OUTPUT -p tcp -o eth0 --sport 1194 -j SSLH \
       ip6tables -t mangle -A OUTPUT -p tcp -o eth0 --sport 51820 -j SSLH \
       ip6tables -t mangle -A OUTPUT -p tcp -o eth0 --sport 80 -j SSLH \
       ip6tables -t mangle -A OUTPUT -p tcp -o eth0 --sport 22 -j SSLH \
       ip6tables -t mangle -A SSLH -j MARK --set-mark 0x1 \
       ip6tables -t mangle -A SSLH -j ACCEPT \
       ip -6 rule add fwmark 0x1 lookup 100 \
       ip -6 route add local ::/0 dev lo table 100

ADD entry.sh /usr/local/bin/entry.sh
RUN chmod +x /usr/local/bin/entry.sh

ENTRYPOINT ["/usr/local/bin/entry.sh"]
