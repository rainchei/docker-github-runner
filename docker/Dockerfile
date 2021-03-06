ARG FROM=ubuntu:trusty
FROM ${FROM}

ARG DEBIAN_FRONTEND=noninteractive
ARG GIT_VERSION="2.26.2"
ARG COMPOSE_VERSION="1.28.5"
ARG GH_RUNNER_VERSION

ENV RUNNER_NAME=""
ENV RUNNER_WORK_DIRECTORY="_work"
ENV RUNNER_TOKEN=""
ENV RUNNER_REPOSITORY_URL=""
ENV RUNNER_LABELS=""
ENV RUNNER_ALLOW_RUNASROOT=true
ENV GITHUB_ACCESS_TOKEN=""
ENV AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache

# Labels.
LABEL maintainer="rainchei.lin@gmail.com" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.name="rainchei/docker-github-runner" \
    org.label-schema.description="Dockerized GitHub Actions runner." \
    org.label-schema.url="https://github.com/rainchei/docker-github-runner" \
    org.label-schema.vcs-url="https://github.com/rainchei/docker-github-runner" \
    org.label-schema.docker.cmd="docker run -it rainchei/docker-github-runner:latest"

RUN DEBIAN_FRONTEND=${DEBIAN_FRONTEND} apt-get update \
    && apt-get install -y \
        curl \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common \
        sudo \
        supervisor \
        jq \
        iputils-ping \
        build-essential \
        zlib1g-dev \
        gettext \
        liblttng-ust0 \
        libcurl4-openssl-dev \
        gnupg-agent \
        awscli

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod 644 /etc/supervisor/conf.d/supervisord.conf

# Install Git
RUN cd /tmp \
    && curl -sL https://www.kernel.org/pub/software/scm/git/git-${GIT_VERSION}.tar.gz -o git.tgz \
    && tar zxf git.tgz \
    && cd git-${GIT_VERSION} \
    && ./configure --prefix=/usr \
    && make \
    && make install

RUN mkdir -p /home/runner ${AGENT_TOOLSDIRECTORY}

WORKDIR /home/runner

# Install Github Runner
RUN GH_RUNNER_VERSION=${GH_RUNNER_VERSION:-$(curl --silent "https://api.github.com/repos/actions/runner/releases/latest" | grep tag_name | sed -E 's/.*"v([^"]+)".*/\1/')} \
    && curl -L -O https://github.com/actions/runner/releases/download/v${GH_RUNNER_VERSION}/actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz \
    && tar -zxf actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz \
    && rm -f actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz \
    && ./bin/installdependencies.sh \
    && chown -R root: /home/runner \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && apt-get clean

## # Install Docker
## https://docs.docker.com/engine/install/ubuntu/
## RUN curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
## RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian buster stable"
## RUN DEBIAN_FRONTEND=${DEBIAN_FRONTEND} apt-get update \
##     && apt-get install -y \
##         docker-ce \
##         docker-ce-cli \
##         containerd.io

## # Install Docker Compose
## RUN sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
##     && sudo chmod +x /usr/local/bin/docker-compose

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
