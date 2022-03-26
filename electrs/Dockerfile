FROM debian:bullseye-slim as builder
ARG BUILDPLATFORM
ARG TARGETPLATFORM
ARG VERSION=v0.9.6
RUN case ${TARGETPLATFORM} in \
       	"linux/amd64")		ELECTRS_ARCH=amd64 		;; \
       	"linux/arm64")		ELECTRS_ARCH=arm64; GCC_POSTFIX=aarch64-linux-gnu		;; \
       	"linux/arm/v7")		ELECTRS_ARCH=armhf; GCC_POSTFIX=arm-linux-gnueabihf	;; \
       	"linux/ppc64le")	ELECTRS_ARCH=ppc64el: GCC_POSTFIX=powerpc64le-linux-gnu	;; \
       esac \
    && dpkg --add-architecture $ELECTRS_ARCH \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       cargo \
       clang \
       cmake \
       git \
       build-essential:${ELECTRS_ARCH} \
       librocksdb-dev:${ELECTRS_ARCH}=6.11.4-3 \
       libc6-dev:${ELECTRS_ARCH} \
       libstd-rust-dev:${ELECTRS_ARCH} \
    && if [ "${BUILDPLATFORM}" != "${TARGETPLATFORM}" ] && [ "${GCC_POSTFIX}" != "" ]; then \
               apt-get install gcc-10-${GCC_POSTFIX} gcc-10-${GCC_POSTFIX}-base \
               && CARGO_CMD='BINDGEN_EXTRA_CLANG_ARGS="-target gcc-${GCC_POSTFIX}" RUSTFLAGS="-C linker=${GCC_POSTFIX}" cargo build --locked --release --target ${GCC_POSTFIX}'; \
           else \
               CARGO_CMD="ROCKSDB_INCLUDE_DIR=/usr/include ROCKSDB_LIB_DIR=/usr/lib cargo build --locked --release"; \
           fi \
    && cd /usr/src \
    && git clone https://github.com/romanz/electrs \
    && cd electrs \
    && git checkout ${VERSION} \
    && ${CARGO_CMD}
            
 
