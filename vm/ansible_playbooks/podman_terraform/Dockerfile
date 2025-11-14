FROM alpine:3.18

ENV TERRAFORM_VERSION=1.7.5

RUN apk add --no-cache curl unzip bash
RUN curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip \
    && unzip terraform.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform.zip
WORKDIR /terraform
ENTRYPOINT ["terraform", "version"]