FROM ubuntu:26.04

ARG RUNNER_VERSION=2.335.1
ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
      ca-certificates \
      curl \
      git \
      jq \
      unzip \
      sudo \
      iproute2 \
      iputils-ping \
      gnupg \
      lsb-release && \
    rm -rf /var/lib/apt/lists/*

#
# Docker CLI (NO daemon)
#
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
      -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo $VERSION_CODENAME) stable" \
      > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

RUN useradd \
      --create-home \
      --shell /bin/bash \
      --uid 1001 \
      runner && \
    usermod -aG sudo runner && \
    echo "runner ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/runner && \
    chmod 0440 /etc/sudoers.d/runner

WORKDIR /home/runner

RUN ARCH=x64 && \
    if [ "$TARGETARCH" = "arm64" ]; then ARCH=arm64; fi && \
    curl -L \
      -o runner.tar.gz \
      https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${ARCH}-${RUNNER_VERSION}.tar.gz && \
    tar xzf runner.tar.gz && \
    rm runner.tar.gz

RUN ./bin/installdependencies.sh

RUN chown -R runner:runner /home/runner

USER runner

ENTRYPOINT ["/home/runner/run.sh"]