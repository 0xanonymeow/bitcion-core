FROM debian:bullseye-slim
LABEL maintainer="0xanonymeow <anonymeow@incatni.to>"
LABEL desciption="A simple docker image for running a bitcoin node"

ARG UID=1000 # $(id -u) or 1000 for default
ARG GID=1000 # $(id -g) or 1000 for default

ENV COIN_USER=coinuser
ENV COIN_GROUP=coingroup
ENV COIN_ROOT_DIR="/home/${COIN_USER}/data"
ENV COIN_RESOURCES="${COIN_ROOT_DIR}/resources"
ENV COIN_WALLETS="${COIN_ROOT_DIR}/wallets"
ENV COIN_LOGS="${COIN_ROOT_DIR}/logs"
ENV COIN_SCRIPTS="${COIN_ROOT_DIR}/scripts"

ENV COIN_VERSION="26.0"
ENV COIN_TMP="/var/tmp"
ENV COIN_CONF_FILE="${COIN_ROOT_DIR}/bitcoin.conf"
ENV TARBALL_NAME="bitcoin-${COIN_VERSION}"

RUN apt-get update -y && \
    apt-get install -y curl ca-certificates apt-transport-https && \
    apt-get clean && \
    addgroup --gid $GID ${COIN_GROUP} && \
    adduser --uid $UID --gid $GID --disabled-password --gecos "" ${COIN_USER} && \
    echo '${COIN_USER} ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

RUN mkdir -m 755 -p ${COIN_ROOT_DIR} && \
    mkdir -m 755 -p ${COIN_RESOURCES} && \
    mkdir -m 700 -p ${COIN_WALLETS} && \
    mkdir -m 755 -p ${COIN_LOGS} && \
    mkdir -m 755 -p ${COIN_SCRIPTS}

RUN chown -R ${COIN_USER}:${COIN_GROUP} ${COIN_ROOT_DIR}
RUN chmod 755 ${COIN_ROOT_DIR}

WORKDIR ${COIN_ROOT_DIR}

RUN MACHINE=$(uname -m) && \
    KERNEL=$(uname -s) && \
    case "$MACHINE" in \
        "x86_64") \
            if [ "$KERNEL" = "Darwin" ]; then \
                ARCH="x86_64-apple-darwin"; \
            else \
                ARCH="x86_64-linux-gnu"; \
            fi ;; \
        "aarch64") ARCH="aarch64-linux-gnu" ;; \
        "armv7"*) ARCH="arm-linux-gnueabihf" ;; \
        "armv6"*) ARCH="arm-linux-gnueabihf" ;; \
        "arm64") \
            if [ "$KERNEL" = "Darwin" ]; then \
                ARCH="arm64-apple-darwin"; \
            else \
                ARCH="aarch64-linux-gnu"; \
            fi ;; \
        "ppc64le") ARCH="powerpc64le-linux-gnu" ;; \
        "ppc64") ARCH="powerpc64-linux-gnu" ;; \
        "riscv64") ARCH="riscv64-linux-gnu" ;; \
        *) exit 1 ;; \
    esac && \
    BINARY_URL="https://bitcoincore.org/bin/bitcoin-core-${COIN_VERSION}/${TARBALL_NAME}-${ARCH}.tar.gz" && \
    curl -L ${BINARY_URL} -o ${COIN_TMP}/${TARBALL_NAME}.tar.gz && \
    tar -xzvf ${COIN_TMP}/${TARBALL_NAME}.tar.gz -C ${COIN_TMP}

RUN mv ${COIN_TMP}/${TARBALL_NAME}/bin/* /usr/bin/ && \
    mv ${COIN_TMP}/${TARBALL_NAME}/include/* /usr/include/ && \
    mv ${COIN_TMP}/${TARBALL_NAME}/lib/* /usr/lib/ && \
    mv --no-clobber ${COIN_TMP}/${TARBALL_NAME}/share/* /usr/share/ && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --chown=${COIN_USER}:${COIN_GROUP} "docker-entrypoint.sh" "/entrypoint.sh"
COPY --chown=${COIN_USER}:${COIN_GROUP} "bitcoin.conf" "${COIN_CONF_FILE}"
COPY --chown=${COIN_USER}:${COIN_GROUP} "scripts/" "${COIN_SCRIPTS}/"

RUN chmod 755 /entrypoint.sh

USER ${COIN_USER}

EXPOSE 8332 8333 18332 18333 18443 18444

VOLUME ["${COIN_ROOT_DIR}"]

ENTRYPOINT ["/entrypoint.sh"]

CMD ["bitcoind"]
