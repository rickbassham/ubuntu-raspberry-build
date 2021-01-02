FROM ubuntu:20.04

ARG UBUNTU_VERSION="focal"
ARG DEBIAN_FRONTEND="noninteractive"
ENV TZ=America/New_York

RUN apt-get update \
    && apt-get install -y apt-utils \
    && dpkg-reconfigure apt-utils \
    && apt-get install -y \
    qemu-user-static debootstrap \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /raspberry
RUN debootstrap --no-check-gpg --foreign --arch=arm64 ${UBUNTU_VERSION} /raspberry http://ports.ubuntu.com
RUN cp /usr/bin/qemu-aarch64-static /raspberry/usr/bin
RUN chroot /raspberry qemu-aarch64-static /bin/bash -c '/debootstrap/debootstrap --second-stage'

RUN chroot /raspberry qemu-aarch64-static /bin/bash -c 'echo "deb http://ports.ubuntu.com ${UBUNTU_VERSION} main multiverse restricted universe" > /etc/apt/sources.list'
RUN chroot /raspberry qemu-aarch64-static /bin/bash -c 'apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*'
RUN chroot /raspberry qemu-aarch64-static /bin/bash -c 'apt-get update && apt-get install -y build-essential devscripts debhelper fakeroot cdbs software-properties-common cmake wget apt-transport-https ca-certificates && rm -rf /var/lib/apt/lists/*'

RUN echo "nameserver 8.8.8.8" > /raspberry/etc/resolv.conf

ENTRYPOINT [ "chroot", "/raspberry", "qemu-aarch64-static" ]
CMD ["/bin/bash"]
