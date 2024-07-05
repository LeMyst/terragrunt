FROM alpine:latest AS downloader

# TERRAFORM VERSION
ARG TERRAFORM_VERSION=1.9.0

# TOFU VERSION
ARG TOFU_VERSION=1.7.2

# TERRAGRUNT VERSION
ARG TERRAGRUNT_VERSION=0.60.0

RUN apk add unzip

WORKDIR /tmp

# Download & unzip TERRAFORM
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip terraform.zip
RUN unzip terraform.zip

# Download & unzip TOFU
ADD https://github.com/opentofu/opentofu/releases/download/v1.6.0-alpha2/tofu_1.6.0-alpha2_linux_amd64.zip tofu.zip
RUN unzip tofu.zip

# Download TERRAGRUNT
ADD https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 terragrunt

FROM golang:alpine

COPY --from=downloader /tmp/terraform /bin/terraform
COPY --from=downloader /tmp/tofu /bin/tofu
COPY --from=downloader /tmp/terragrunt /bin/terragrunt

RUN apk add --update --upgrade --no-cache bash git openssh && rm -rf /var/cache/apt/*

RUN chmod +x /bin/terraform
RUN chmod +x /bin/tofu
RUN chmod +x /bin/terragrunt

ENTRYPOINT ["terragrunt", "--version"]
