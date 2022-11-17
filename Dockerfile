FROM amd64/ubuntu:20.04 as ld-prefix
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y install ca-certificates libicu66 libssl1.1

FROM s390x/ubuntu:20.04
COPY --from=ld-prefix / /usr/x86_64-linux-gnu/

RUN md5sum /usr/x86_64-linux-gnu/etc/passwd
RUN cat /usr/x86_64-linux-gnu/etc/passwd
RUN md5sum /etc/passwd /etc/group
RUN cat /etc/passwd
RUN cat /etc/group
RUN addgroup --system kvm
RUN md5sum /etc/group
RUN cat /etc/group
RUN apt-get update && apt-get install -y dbus
RUN md5sum /etc/group
RUN cat /etc/group
