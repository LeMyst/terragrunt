ARG TERRAFORM_VERSION=1.4.6

FROM hashicorp/terraform:$TERRAFORM_VERSION

ARG TERRAGRUNT_VERSION=0.45.6

RUN apk add --update --upgrade --no-cache bash git openssh

ADD https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 /bin/terragrunt

RUN chmod +x /bin/terragrunt

ENTRYPOINT []
