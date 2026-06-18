FROM ibmcom/db2

USER root

RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/*.repo && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/*.repo

RUN dnf clean all && \
    dnf install -y gnucobol nmap-ncat

COPY iniciar-netcat.sh /var/custom/iniciar-netcat.sh
RUN chmod +x /var/custom/iniciar-netcat.sh