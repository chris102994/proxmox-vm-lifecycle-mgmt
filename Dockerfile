FROM hashicorp/packer:light AS packer
FROM hashicorp/terraform:1.8.1 AS terraform
FROM quay.io/coreos/butane:release AS butane

FROM ubuntu:noble

COPY --from=packer    /bin/packer           /bin/packer
COPY --from=terraform /bin/terraform        /bin/terraform
COPY --from=butane    /usr/local/bin/butane /bin/butane

RUN \
    apt-get update && \
    apt-get install -y \
        ansible \
        ansible-lint \
        ca-certificates \
        colorized-logs \
        curl \
        genisoimage \
        jq \
        whois \
        xorriso && \
    sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /bin && \
    curl -sL https://talos.dev/install | sh && \
    mkdir -p /work && \
    apt-get clean

COPY ansible/requirements.yml /tmp/requirements.yml
RUN \
    ansible-galaxy collection install -r /tmp/requirements.yml && \
    rm -f /tmp/requirements.yml

WORKDIR /work
ENTRYPOINT ["/bin/task"]
