FROM ubuntu:22.04

ADD scripts/snx_install.sh /root

RUN mkdir /dev/net \
  && mknod /dev/net/tun c 10 200 \
  && chmod 0666 /dev/net/tun

RUN dpkg --add-architecture i386

RUN apt-get update \
  && apt-mark hold grub* grub*:i386 \
  && apt-get install -y apt --no-install-recommends \
  && apt-get install -y kmod --no-install-recommends \
  && apt-get install -y --no-install-recommends --reinstall linux-headers-$(uname -r) \
  && apt-get install -y --no-install-recommends --reinstall linux-image-$(uname -r) \
  && apt-get update -y \
  && apt-get upgrade -y

RUN depmod

RUN apt-get install -y --no-install-recommends bzip2 kmod libstdc++6:i386 libstdc++5:i386 libpam0g:i386 libx11-6:i386 expect iptables net-tools iputils-ping iproute2

RUN modprobe tun   

RUN cd /root && bash -x snx_install.sh

ADD scripts/snx.sh /root

RUN chmod +x /root/snx.sh

CMD ["/root/snx.sh"]