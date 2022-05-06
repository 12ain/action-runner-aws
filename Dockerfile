FROM debian:buster as builder

# Install required system packages and dependencies
ADD ./install_packages /install_packages
RUN chmod +x /install_packages
RUN ./install_packages ca-certificates curl procps sudo unzip curl

# "Install" kubectl
RUN curl -L https://dl.k8s.io/release/v1.21.0/bin/linux/amd64/kubectl > /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl

# install the aws-iam-authenticator
RUN curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/aws-iam-authenticator && \
    chmod +x ./aws-iam-authenticator && mv ./aws-iam-authenticator /usr/local/bin/


FROM ghcr.io/actions-runner-controller/actions-runner-controller/actions-runner:v2.291.1-ubuntu-20.04-800d6bd
LABEL maintainer "lwnmengjing  <lwnmengjing@qq.com>"

RUN sudo apt update -y && sudo apt-get install -y gettext

COPY --from=builder /usr/bin/kubectl /usr/local/bin/
COPY --from=builder /usr/local/bin/aws-iam-authenticator /usr/local/bin/
RUN /usr/local/bin/kubectl -h
RUN pip install awscli aws-sam-cli
RUN /usr/local/bin/aws-iam-authenticator -h
