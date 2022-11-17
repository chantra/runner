FROM s390x/ubuntu:20.04

RUN md5sum /etc/passwd /etc/group
RUN cat /etc/passwd
RUN cat /etc/group
RUN addgroup --system kvm
RUN md5sum /etc/group
RUN cat /etc/group
RUN apt-get update && apt-get install -y dbus
RUN md5sum /etc/group
RUN cat /etc/group
