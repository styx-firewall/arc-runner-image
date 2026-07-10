FROM ubuntu:26.04

ARG RUNNER_VERSION=2.335.1
ARG RUNNER_CONTAINER_HOOKS_VERSION=0.8.1
ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive
ENV RUNNER_MANUALLY_TRAP_SIG=1
ENV ACTIONS_RUNNER_PRINT_LOG_TO_STDOUT=1

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    unzip \
    git \
    jq \
    sudo \
    iproute2 \
    iputils-ping \
    docker.io \
    && rm -rf /var/lib/apt/lists/*

RUN useradd \
    --create-home \
    --shell /bin/bash \
    --uid 1001 \
    runner \
 && groupadd -g 123 docker \
 && usermod -aG docker runner \
 && usermod -aG sudo runner \
 && echo "%sudo ALL=(ALL:ALL) NOPASSWD:ALL" >/etc/sudoers \
 && echo "Defaults env_keep += \"DEBIAN_FRONTEND\"" >> /etc/sudoers

WORKDIR /home/runner

RUN ARCH=x64 && \
    if [ "$TARGETARCH" = "arm64" ]; then ARCH=arm64; fi && \
    curl -fsSL \
      -o runner.tar.gz \
      https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${ARCH}-${RUNNER_VERSION}.tar.gz && \
    tar xzf runner.tar.gz && \
    rm runner.tar.gz

RUN curl -fsSL \
      -o hooks.zip \
      https://github.com/actions/runner-container-hooks/releases/download/v${RUNNER_CONTAINER_HOOKS_VERSION}/actions-runner-hooks-k8s-${RUNNER_CONTAINER_HOOKS_VERSION}.zip && \
    unzip hooks.zip -d ./k8s && \
    rm hooks.zip

RUN chown -R runner:runner /home/runner

USER runner

ENTRYPOINT ["/home/runner/run.sh"]