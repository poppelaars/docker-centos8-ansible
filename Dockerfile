# https://hub.docker.com/_/centos/
FROM centos:8
LABEL maintainer="Chris Poppelaars"

ENV container docker

RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial; \
    dnf makecache; \
    dnf install -y rpm centos-release dnf-plugins-core; \
    dnf update -y; \
    dnf config-manager --set-enabled powertools -y; \
    dnf install -y \
        epel-release \
        initscripts \
        sudo \
        which \
        wget \
        hostname \
        libyaml-devel \
        python3 \
        python3-pip \
        python3-pyyaml; \
    dnf clean all;

RUN (cd /lib/systemd/system/sysinit.target.wants/; \
    for i in *; \
    do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; \
    done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*; \
    rm -f /etc/systemd/system/*.wants/*; \
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*; \
    rm -f /lib/systemd/system/anaconda.target.wants/*;

# Disable requiretty.
RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers

ENV PATH "$PATH:/root/.local/bin"

RUN pip3 install --upgrade pip
RUN pip3 install ansible

# Configure Ansible inventory file.
RUN mkdir -p /etc/ansible
RUN echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

VOLUME [ "/sys/fs/cgroup" ]
CMD [ "/usr/sbin/init" ]
