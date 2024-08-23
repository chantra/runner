# Self-Hosted IBM Z Github Actions Runner.
ARG UBUNTU_VERSION=focal
# Main image.
FROM s390x/ubuntu:${UBUNTU_VERSION}
# Redefining UBUNTU_VERSION without a value inherits the global default
ARG UBUNTU_VERSION

RUN apt-get update \
  && apt-get install -y cmake flex bison build-essential libssl-dev ncurses-dev xz-utils bc rsync libguestfs-tools qemu-kvm qemu-utils linux-image-generic zstd binutils-dev elfutils libcap-dev libelf-dev libdw-dev python3-docutils \
  && apt-get install -y g++ libelf-dev \
  && apt-get install -y iproute2 iputils-ping \
  && apt-get install -y cpu-checker qemu-kvm qemu-utils qemu-system-x86 qemu-system-s390x qemu-system-arm qemu-guest-agent ethtool keyutils iptables gawk \
  && echo "deb https://apt.llvm.org/${UBUNTU_VERSION}/ llvm-toolchain-${UBUNTU_VERSION} main" > /etc/apt/sources.list.d/llvm.list \
  && wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
  && apt-get update \
  && apt-get install -y clang lld llvm

## s390x runner native install taken from https://github.com/anup-kodlekere/gaplib
ARG VERSION=2.317.0
ARG SDK=6
ARG  RUNNERREPO="https://github.com/actions/runner"
RUN apt-get update \
  && apt-get install -y alien

# copy scripts/patch from anup-kodlekere/gaplib
RUN curl -L https://raw.githubusercontent.com/anup-kodlekere/gaplib/main/build-files/convert-rpm.sh -o /tmp/convert-rpm.sh && chmod 755 /tmp/convert-rpm.sh
RUN curl -L https://raw.githubusercontent.com/anup-kodlekere/gaplib/main/build-files/runner-s390x.patch -o /tmp/runner.patch

RUN /tmp/convert-rpm.sh ${SDK}

RUN dpkg --install /tmp/*.deb && \
  rm -rf /tmp/*.deb && \
  echo "Using SDK - `dotnet --version`"


RUN cd /tmp && \
  git clone -q ${RUNNERREPO} && \
  cd runner && \
  git checkout v${VERSION} -b build && \
  sed -i'' -e /version/s/6......\"$/${SDK}.0.100\"/ src/global.json && \
  git apply /tmp/runner.patch

RUN cd /tmp/runner/src && \
  ./dev.sh layout && \
  ./dev.sh package && \
  ./dev.sh test && \
  rm -rf /root/.dotnet /root/.nuget


# amd64 Github Actions Runner.
ARG HOMEDIR=/actions-runner
# Copy scripts from  myoung34/docker-github-actions-runner
RUN curl -L https://raw.githubusercontent.com/myoung34/docker-github-actions-runner/${VERSION}/entrypoint.sh -o /entrypoint.sh && chmod 755 /entrypoint.sh
RUN curl -L https://raw.githubusercontent.com/myoung34/docker-github-actions-runner/${VERSION}/token.sh -o /token.sh && chmod 755 /token.sh

RUN useradd -d ${HOMEDIR} -m runner
RUN echo "runner ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers
RUN echo "Defaults env_keep += \"DEBIAN_FRONTEND\"" >>/etc/sudoers
# Make sure kvm group exists. This is a no-op when it does.
RUN addgroup --system kvm
RUN usermod -a -G kvm runner
USER runner
ENV USER=runner
WORKDIR ${HOMEDIR}
USER root

ENTRYPOINT ["/entrypoint.sh"]
CMD ["./bin/Runner.Listener", "run", "--startuptype", "service"]
