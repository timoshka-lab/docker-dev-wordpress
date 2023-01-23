ARG MYSQL_VERSION=8.0
FROM mysql:${MYSQL_VERSION}
RUN microdnf install -y sudo && \
    microdnf clean all