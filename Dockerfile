FROM alpine:latest AS downloader

# Install GPG
RUN apk add --no-cache gnupg cosign

# TERRAFORM VERSION
ARG TERRAFORM_VERSION=1.9.3

# TOFU VERSION
ARG TOFU_VERSION=1.8.0

# TERRAGRUNT VERSION
ARG TERRAGRUNT_VERSION=0.64.4

RUN apk add unzip

WORKDIR /tmp

# Download hashicorp public key
ADD https://keybase.io/hashicorp/pgp_keys.asc hashicorp.asc
RUN gpg --batch --import --lock-never hashicorp.asc

# Download & check & unzip TERRAFORM
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS terraform_SHA256SUMS
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig terraform_SHA256SUMS.sig
RUN gpg --verify terraform_SHA256SUMS.sig terraform_SHA256SUMS
RUN grep linux_amd64.zip terraform_SHA256SUMS | sha256sum -c -
RUN unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Download & check & unzip TOFU
ADD https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}/tofu_${TOFU_VERSION}_linux_amd64.zip tofu_${TOFU_VERSION}_linux_amd64.zip
ADD https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}/tofu_${TOFU_VERSION}_SHA256SUMS tofu_${TOFU_VERSION}_SHA256SUMS
ADD https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}/tofu_${TOFU_VERSION}_SHA256SUMS.sig tofu_${TOFU_VERSION}_SHA256SUMS.sig
ADD https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}/tofu_${TOFU_VERSION}_SHA256SUMS.pem tofu_${TOFU_VERSION}_SHA256SUMS.pem
RUN cosign verify-blob --certificate-identity "https://github.com/opentofu/opentofu/.github/workflows/release.yml@refs/heads/v${TOFU_VERSION%.*}" --signature "tofu_${TOFU_VERSION}_SHA256SUMS.sig" --certificate "tofu_${TOFU_VERSION}_SHA256SUMS.pem" --certificate-oidc-issuer "https://token.actions.githubusercontent.com" tofu_${TOFU_VERSION}_SHA256SUMS
RUN grep linux_amd64.zip tofu_${TOFU_VERSION}_SHA256SUMS | sha256sum -c -
RUN unzip tofu_${TOFU_VERSION}_linux_amd64.zip

# Download TERRAGRUNT
ADD https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 terragrunt_linux_amd64
ADD https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/SHA256SUMS terragrunt_SHA256SUMS
RUN grep linux_amd64 terragrunt_SHA256SUMS | sha256sum -c -

FROM golang:alpine

COPY --from=downloader /tmp/terraform /bin/terraform
COPY --from=downloader /tmp/tofu /bin/tofu
COPY --from=downloader /tmp/terragrunt_linux_amd64 /bin/terragrunt

RUN apk add --update --upgrade --no-cache bash git openssh && rm -rf /var/cache/apt/*

RUN chmod +x /bin/terraform
RUN chmod +x /bin/tofu
RUN chmod +x /bin/terragrunt

ENTRYPOINT ["terragrunt", "--version"]
