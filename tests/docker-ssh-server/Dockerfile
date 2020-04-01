FROM debian:buster-slim

###
### Install SSH Server
###
RUN set -eux \
	&& apt update \
	&& apt install -y \
		rsync \
		openssh-server

###
### Configure SSH
###
RUN set -eux \
	&& mkdir -p /var/run/sshd \
	&& chmod 0755 /var/run/sshd \
	\
	&& mkdir -p /root/.ssh \
	&& chmod 0700 /root/.ssh

###
### Add public key
###
COPY id_rsa.pub /root/.ssh/authorized_keys
RUN set -eux && chmod 0400 /root/.ssh/authorized_keys

###
### Add backup directories
###
RUN set -eux \
	&& mkdir -p /root/backup1 \
	&& mkdir -p /backup2

CMD ["/usr/sbin/sshd", "-D"]
