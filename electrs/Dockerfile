FROM debian:bullseye-slim as builder
ARG BUILDPLATFORM
ARG TARGETPLATFORM
ARG VERSION=v0.9.6
ENV ROCKSDB_INCLUDE_DIR=/usr/include
ENV ROCKSDB_LIB_DIR=/usr/lib
RUN case ${TARGETPLATFORM} in \
       	"linux/amd64")		ELECTRS_ARCH=amd64 		;; \
       	"linux/arm64")		ELECTRS_ARCH=arm64; GCC_POSTFIX=aarch64-linux-gnu		;; \
       	"linux/arm/v7")		ELECTRS_ARCH=armhf; GCC_POSTFIX=arm-linux-gnueabihf	;; \
       	"linux/ppc64le")	ELECTRS_ARCH=ppc64el: GCC_POSTFIX=powerpc64le-linux-gnu	;; \
       esac \
    && dpkg --add-architecture $ELECTRS_ARCH \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       cargo \
       clang \
       cmake \
       git \
       build-essential:${ELECTRS_ARCH} \
       librocksdb-dev:${ELECTRS_ARCH}=6.11.4-3 \
       libc6-dev:${ELECTRS_ARCH} \
       libstd-rust-dev:${ELECTRS_ARCH} \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && if [ "${BUILDPLATFORM}" != "${TARGETPLATFORM}" ] && [ "${GCC_POSTFIX}" != "" ]; then \
               apt-get install gcc-10-${GCC_POSTFIX} gcc-10-${GCC_POSTFIX}-base \
               && BINDGEN_EXTRA_CLANG_ARGS="-target gcc-${GCC_POSTFIX}" \
               && RUSTFLAGS="-C linker=${GCC_POSTFIX}" \
               && CARGO_CMD='cargo build --locked --release'; \
           else \
               CARGO_CMD="cargo build --locked --release"; \
           fi \
    && cd /usr/src \
    && git clone https://github.com/romanz/electrs \
    && cd electrs \
    && git checkout ${VERSION} \
    && cargo build --locked --release

FROM debian:bullseye-slim

ENTRYPOINT ["electrs-entrypoint.sh", "--conf", "/data/electrs.conf"]

ENV HOME /electrs
WORKDIR /electrs

ARG GROUP_ID=1000
ARG USER_ID=1000

ARG TARGETPLATFORM
RUN case ${TARGETPLATFORM} in \
       	"linux/amd64")		ELECTRS_ARCH=amd64 		;; \
       	"linux/arm64")		ELECTRS_ARCH=arm64; GCC_POSTFIX=aarch64-linux-gnu		;; \
       	"linux/arm/v7")		ELECTRS_ARCH=armhf; GCC_POSTFIX=arm-linux-gnueabihf	;; \
       	"linux/ppc64le")	ELECTRS_ARCH=ppc64el: GCC_POSTFIX=powerpc64le-linux-gnu	;; \
       esac \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       librocksdb-dev:${ELECTRS_ARCH}=6.11.4-3 \
       curl \
       gosu \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && unset ELECTRS_ARCH \
    && gosu nobody true \
    && groupadd -g ${GROUP_ID} electrs \
    && useradd -u ${USER_ID} -g electrs -d /electrs electrs

COPY --from=builder /usr/src/electrs/target/release/electrs /usr/local/bin/
COPY electrs-entrypoint.sh /usr/local/bin
