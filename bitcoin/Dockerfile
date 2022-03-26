FROM ubuntu:latest as builder

ARG TARGETPLATFORM
ARG VERSION=22.0
# https://github.com/bitcoin/bitcoin/tree/v22.0/contrib/builder-keys
ARG BITCOIN_SIGNATURES_URL=https://raw.githubusercontent.com/bitcoin/bitcoin/v22.0/contrib/builder-keys/keys.txt
ARG BITCOIN_MIN_VERIFIED=3

RUN apt update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        gnupg \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    cd /tmp \
    && case ${TARGETPLATFORM} in \
       	"linux/amd64")		BITCOIN_ARCH=x86_64-linux-gnu		;; \
       	"linux/arm64")		BITCOIN_ARCH=aarch64-linux-gnu		;; \
       	"linux/arm/v7")		BITCOIN_ARCH=arm-linux-gnueabihf	;; \
       	"linux/riscv64")	BITCOIN_ARCH=riscv64-linux-gnu		;; \
       	"linux/ppc64le")	BITCOIN_ARCH=powerpc64le-linux-gnu	;; \
       esac \
    && wget ${BITCOIN_SIGNATURES_URL} \
    && while read fingerprint keyholder_name; do \
    gpg --keyserver hkp://keyserver.ubuntu.com  --recv-keys ${fingerprint}; done < ./keys.txt \
    && wget "https://bitcoincore.org/bin/bitcoin-core-${VERSION}/bitcoin-${VERSION}-${BITCOIN_ARCH}.tar.gz" \
            "https://bitcoincore.org/bin/bitcoin-core-${VERSION}/SHA256SUMS" \
            "https://bitcoincore.org/bin/bitcoin-core-${VERSION}/SHA256SUMS.asc" \
    && test $(gpg --verify --status-fd 1 SHA256SUMS.asc 2> /dev/null | \
              grep "^\[GNUPG:\] VALIDSIG" | grep -E $(awk '{printf "%s|",$1}' keys.txt) | wc -l) -ge ${BITCOIN_MIN_VERIFIED} \
    && sha256sum --ignore-missing --check SHA256SUMS \
    && tar -xvf bitcoin-${VERSION}-${BITCOIN_ARCH}.tar.gz --strip-components=1 -C /usr/local/

FROM ubuntu:latest

ENTRYPOINT ["bitcoin-entrypoint.sh"]
ENV HOME /bitcoin
WORKDIR /bitcoin

ARG GROUP_ID=1000
ARG USER_ID=1000
RUN groupadd -g ${GROUP_ID} bitcoin \
    && useradd -u ${USER_ID} -g bitcoin -d /bitcoin bitcoin \
    && apt-get update \
    && apt-get install -y --no-install-recommends gosu \
    && gosu nobody true \
    && apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=builder /usr/local/ /usr/local/
COPY bitcoin-entrypoint.sh /usr/local/bin
