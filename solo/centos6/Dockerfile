FROM centos:6
RUN yum upgrade -y \
	&& yum install -y epel-release
RUN yum install -q -y \
	git \
	vim-enhanced \
	wget \
	gcc \
	gpg \
	ccache \
	unzip \
	pigz \
	xz \
	sudo \
	passwd \
	openssh-server \
	ed \
	readline-devel \
	zlib-devel \
	curl-devel \
	bzip2-devel \
	python-devel \
	apr-devel \
	libevent-devel \
	openssl-libs \
	openssl-devel \
	libyaml \
	libyaml-devel \
	epel-release \
	htop \
	perl-Env \
	perl-ExtUtils-Embed \
	libxml2-devel \
	libxslt-devel \
	libffi-devel \
	file \
	python-pip

RUN pip install \
	psutil \
	lockfile \
	paramiko \
	epydoc

ADD gpdb.tar.xz /build/install
EXPOSE 5432

# backport the no-tty fix from RHEL7 to RHEL5
RUN sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers

# generate server keys
RUN service sshd start

RUN useradd --password '$5$uitFy1zdHuG$f7NutSS0aAyl7EqqPBhKZOk4iKJzxFkGGYd8s2hERM8' --group adm gpadmin \
	&& echo '%adm ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN mkdir -p /data/master /data/primary \
	&& chown -R gpadmin /data

USER gpadmin

RUN ssh-keygen -f ~/.ssh/id_rsa -N '' && cp ~/.ssh/{id_rsa.pub,authorized_keys}

ENTRYPOINT /entrypoint.bash
COPY entrypoint.bash /
