FROM amd64/ubuntu:20.04 as ld-prefix
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y install ca-certificates libicu66 libssl1.1

FROM s390x/ubuntu:20.04
# Packages for libbpf testing that are not installed by .github/actions/setup.
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y install \
        bc \
        bison \
        cmake \
        cpu-checker \
        curl \
        dumb-init \
        wget \
        flex \
        git \
        jq \
        linux-image-generic \
        qemu-system-s390x \
        rsync \
        software-properties-common \
        sudo \
        tree \
        zstd \
        iproute2 \
        iputils-ping
# amd64 dependencies.
COPY --from=ld-prefix / /usr/x86_64-linux-gnu/
RUN ln -fs ../lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 /usr/x86_64-linux-gnu/lib64/
#RUN ln -fs /etc/resolv.conf /usr/x86_64-linux-gnu/etc/
#ENV QEMU_LD_PREFIX=/usr/x86_64-linux-gnu

# amd64 Github Actions Runner.
#ARG version=2.299.1
#ARG homedir=/actions-runner
# Copy scripts from  myoung34/docker-github-actions-runner
#RUN curl -L https://raw.githubusercontent.com/myoung34/docker-github-actions-runner/${version}/entrypoint.sh -o /entrypoint.sh && chmod 755 /entrypoint.sh
#RUN curl -L https://raw.githubusercontent.com/myoung34/docker-github-actions-runner/${version}/token.sh -o /token.sh && chmod 755 /token.sh

#RUN useradd -d ${homedir} -m runner
#RUN echo "runner ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers
#RUN echo "Defaults env_keep += \"DEBIAN_FRONTEND\"" >>/etc/sudoers
#RUN addgroup --system kvm
#RUN usermod -a -G kvm runner
#USER runner
#ENV USER=runner
#WORKDIR ${homedir}
#RUN curl -L https://github.com/actions/runner/releases/download/v${version}/actions-runner-linux-x64-${version}.tar.gz | tar -xz
#USER root

#VOLUME ${homedir}

#ENTRYPOINT ["/entrypoint.sh"]
#CMD ["./bin/Runner.Listener", "run", "--startuptype", "service"]

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


