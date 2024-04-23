FROM hashicorp/packer:light as PACKER
FROM hashicorp/terraform:1.8.1 as TERRAFORM
FROM quay.io/coreos/butane:release as BUTANE

FROM ubuntu:noble

COPY --from=PACKER    /bin/packer           /bin/packer
COPY --from=TERRAFORM /bin/terraform        /bin/terraform
COPY --from=BUTANE    /usr/local/bin/butane /bin/butane

RUN \
    apt-get update && \
    apt-get install -y \
        ansible \
        ansible-lint \
        ca-certificates \
        curl \
        genisoimage \
        whois \
        xorriso && \
    sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /bin && \
    mkdir -p /work && \
    apt-get clean

COPY ansible/requirements.yml /tmp/requirements.yml
RUN \
    ansible-galaxy collection install -r /tmp/requirements.yml && \
    rm -f /tmp/requirements.yml

WORKDIR /work
ENTRYPOINT ["/bin/task"]
