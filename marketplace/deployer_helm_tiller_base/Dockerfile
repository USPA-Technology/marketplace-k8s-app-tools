FROM marketplace.gcr.io/google/python

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    gettext \
    git \
    jq \
    procps \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install \
      wheel \
      pyOpenSSL \
      pyyaml \
      six

RUN for full_version in 1.15.12 1.16.15 1.17.14 1.18.12;  \
     do \
        version=${full_version%.*} \
        && mkdir -p /opt/kubectl/$version \
        && wget -q -O /opt/kubectl/$version/kubectl \
            https://storage.googleapis.com/kubernetes-release/release/v$full_version/bin/linux/amd64/kubectl \
        && chmod 755 /opt/kubectl/$version/kubectl; \
     done;
RUN ln -s /opt/kubectl/1.17 /opt/kubectl/default

RUN mkdir -p /bin/helm-downloaded \
    && wget -q -O /bin/helm-downloaded/helm.tar.gz \
        https://storage.googleapis.com/kubernetes-helm/helm-v2.17.0-linux-amd64.tar.gz \
    && tar -zxvf /bin/helm-downloaded/helm.tar.gz -C /bin/helm-downloaded \
    && mv /bin/helm-downloaded/linux-amd64/helm /bin/ \
    && rm -rf /bin/helm-downloaded \
    && helm init --client-only \
    && helm plugin install https://github.com/rimusz/helm-tiller \
    && helm repo add cloud-marketplace-tools-charts https://cloud-marketplace-tools.storage.googleapis.com/charts

COPY marketplace/deployer_util/* /bin/
COPY marketplace/deployer_helm_tiller_base/bin/* /bin/

RUN mkdir -p /data/chart

ENTRYPOINT ["/bin/bash", "/bin/deploy.sh"]
