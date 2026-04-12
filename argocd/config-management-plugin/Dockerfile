FROM alpine:3.22.3

ARG TIMONI_VERSION=0.25.2

RUN curl -Lo /tmp/timoni.tar.gz "https://github.com/stefanprodan/timoni/releases/download/v${TIMONI_VERSION}/timoni_${TIMONI_VERSION}_linux_amd64.tar.gz" && \
    tar -xzf /tmp/timoni.tar.gz -C /usr/local/bin && \
    rm /tmp/timoni.tar.gz

USER argocd

RUN mkdir -p /home/argocd/cmp-server/config
COPY plugin.yml /home/argocd/cmp-server/config/plugin.yaml

ENTRYPOINT [ "/var/run/argocd/argocd-cmp-server" ]