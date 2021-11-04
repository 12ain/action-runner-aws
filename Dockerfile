FROM debian:buster as builder

# Install required system packages and dependencies
ADD ./install_packages /install_packages
RUN chmod +x /install_packages
RUN ./install_packages ca-certificates curl procps sudo unzip curl

# "Install" kubectl
RUN curl -L https://dl.k8s.io/release/v1.21.0/bin/linux/amd64/kubectl > /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl

# install the awscli
RUN curl -L "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"  >   \
    /awscliv2.zip && unzip awscliv2.zip &&sudo ./aws/install && /usr/local/bin/aws --version

# install the aws-iam-authenticator
RUN curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/aws-iam-authenticator && \
    chmod +x ./aws-iam-authenticator && mv ./aws-iam-authenticator /usr/local/bin/


FROM summerwind/actions-runner:latest
LABEL maintainer "lwnmengjing  <991154416@qq.com>"

COPY --from=builder ./aws ./aws
RUN sudo ./aws/install
RUN sudo rm -rf ./aws
COPY --from=builder /usr/bin/kubectl /usr/local/bin/
COPY --from=builder /usr/local/bin/aws-iam-authenticator /usr/local/bin/
RUN /usr/local/bin/kubectl -h
RUN /usr/local/bin/aws -h
RUN /usr/local/bin/aws-iam-authenticator -h
