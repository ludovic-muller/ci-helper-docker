######################
# CONFIGURE VERSIONS #
######################

# https://github.com/GoogleContainerTools/kaniko/releases
ARG KANIKO_VERSION="1.9.1"

# https://github.com/google/go-containerregistry/releases
ARG GO_CONTAINERREGISTRY_VERSION="0.12.1"



################
# FETCH KANIKO #
################

FROM gcr.io/kaniko-project/executor:v${KANIKO_VERSION} as kaniko-bin



#####################
# BUILD FINAL IMAGE #
#####################

FROM ghcr.io/ludovic-muller/alpine:main

# make sure that the configured versions are available for this layer
ARG GO_CONTAINERREGISTRY_VERSION

# configure some default environment variables
ENV PAGER="less"
ENV EDITOR="vim"

# install some tools
COPY --from=kaniko-bin /kaniko/executor /kaniko/executor
RUN ln -s /kaniko/executor /usr/local/bin/executor
RUN apk add --no-cache jq vim bash less git rsync curl wget unzip
RUN wget -qO - https://github.com/google/go-containerregistry/releases/download/v${GO_CONTAINERREGISTRY_VERSION}/go-containerregistry_Linux_x86_64.tar.gz | tar xzvC /usr/local/bin crane

WORKDIR /aws
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && ./aws/install && rm -rf aws awscliv2.zip
WORKDIR /root
RUN rm -rf /aws

# create some directories
RUN mkdir -p "${HOME}/.docker"

# import custom tools/scripts
COPY tools/ecrane /usr/local/bin/ecrane

# make sure they are executable
RUN chmod +x /usr/local/bin/ecrane
