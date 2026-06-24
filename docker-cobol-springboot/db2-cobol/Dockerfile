FROM ibmcom/db2

USER root

RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/*.repo && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/*.repo

RUN dnf clean all && \
    dnf install -y gnucobol nmap-ncat

COPY iniciar-netcat.sh /var/custom/iniciar-netcat.sh
COPY esquema.sql /var/custom/scripts-db/esquema.sql
COPY datos.sql /var/custom/scripts-db/datos.sql
RUN chmod +x /var/custom/iniciar-netcat.sh && chmod -R 755 /var/custom/scripts-db/