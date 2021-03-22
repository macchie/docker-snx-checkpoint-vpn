FROM ubuntu:18.04

RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y bzip2 kmod libstdc++5:i386 libpam0g:i386 libx11-6:i386 expect iptables net-tools iputils-ping iproute2

ADD scripts/snx_install_linux30.sh /root/snx_install.sh

RUN cd /root && bash -x snx_install.sh

ADD scripts/snx.sh /root

RUN chmod +x /root/snx.sh

CMD ["/root/snx.sh"]
