FROM alpine
MAINTAINER David Kirstein <dak@batix.com>

# combining stuff from:
# https://github.com/colebrumley/docker-rundeck
# https://github.com/William-Yeh/docker-ansible

ENV RDECK_BASE=/opt/rundeck
ENV RDECK_JAR=${RDECK_BASE}/rundeck-launcher.jar
ENV PATH=${PATH}:${RDECK_BASE}/tools/bin
ENV MANPATH=${MANPATH}:${RDECK_BASE}/docs/man
ENV RDECK_ADMIN_PASS=rdtest2017
ENV PROJECT_BASE=${RDECK_BASE}/projects/Test-Project
ENV ANSIBLE_HOST_KEY_CHECKING=false
ENV RDECK_HOST=localhost
ENV RDECK_PORT=4440

# install Ansible and Java, create directories
# check newest version: https://pypi.python.org/pypi/ansible
RUN apk --no-cache add sudo python py-pip openssl ca-certificates openjdk8-jre bash curl && \
  apk --no-cache add --virtual build-deps python-dev libffi-dev openssl-dev build-base && \
  pip --no-cache-dir install --upgrade pip cffi && \
  pip --no-cache-dir install ansible==2.3.2.0 && \
  apk del build-deps && \
  mkdir -p /etc/ansible \
  ${PROJECT_BASE}/acls \
  ${PROJECT_BASE}/etc \
  ${RDECK_BASE}/libext

# install Rundeck via launcher
# check newest version: http://rundeck.org/downloads.html
RUN curl -SLo ${RDECK_JAR} http://dl.bintray.com/rundeck/rundeck-maven/rundeck-launcher-2.10.2.jar
COPY docker/realm.properties ${RDECK_BASE}/server/config/
COPY docker/run.sh /
RUN chmod +x /run.sh

# install plugin from GitHub
# check newest version: https://github.com/Batix/rundeck-ansible-plugin/releases
#RUN curl -SLo ${RDECK_BASE}/libext/ansible-plugin.jar https://github.com/Batix/rundeck-ansible-plugin/releases/download/2.1.0/ansible-plugin-2.1.0.jar

# install locally built plugin
COPY build/libs/ansible-plugin-*.jar ${RDECK_BASE}/libext/

# create project
COPY docker/project.properties ${PROJECT_BASE}/etc/

CMD /run.sh
