FROM debian:bullseye-slim
LABEL maintainer="0xanonymeow <anonymeow@incatni.to>"
LABEL desciption="A simple docker image for running a bitcoin node"

ENV COIN_ROOT_DIR="/data"
ENV COIN_RESOURCES="${COIN_ROOT_DIR}/resources"
ENV COIN_WALLETS="${COIN_ROOT_DIR}/wallets"
ENV COIN_LOGS="${COIN_ROOT_DIR}/logs"
ENV COIN_SCRIPTS="${COIN_ROOT_DIR}/scripts"

ENV COIN_VERSION="26.0"
ENV TARBALL_NAME="bitcoin-${COIN_VERSION}"
ENV BINARY_URL="https://bitcoincore.org/bin/bitcoin-core-${COIN_VERSION}/${TARBALL_NAME}-x86_64-linux-gnu.tar.gz"
ENV COIN_TMP="/var/tmp/"
ENV COIN_CONF_FILE="${COIN_ROOT_DIR}/bitcoin.conf"

RUN apt-get update -y && \
    apt-get install -y curl gosu ca-certificates apt-transport-https && \
    apt-get clean

RUN mkdir -p ${COIN_ROOT_DIR} && \
    mkdir -p ${COIN_RESOURCES} && \
    mkdir -p ${COIN_WALLETS} && \
    mkdir -p ${COIN_LOGS} && \
    mkdir -p ${COIN_SCRIPTS}

WORKDIR ${COIN_ROOT_DIR}

RUN curl -L ${BINARY_URL} -o ${COIN_TMP}/${TARBALL_NAME}.tar.gz && \
    tar -xvf ${COIN_TMP}/${TARBALL_NAME}.tar.gz -C ${COIN_TMP}

RUN mv ${COIN_TMP}/${TARBALL_NAME}/bin/* /usr/bin/ && \
    mv ${COIN_TMP}/${TARBALL_NAME}/include/* /usr/include/ && \
    mv ${COIN_TMP}/${TARBALL_NAME}/lib/* /usr/lib/ && \
    mv ${COIN_TMP}/${TARBALL_NAME}/share/* /usr/share/ && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apt/*

COPY "docker-entrypoint.sh" "/entrypoint.sh"
COPY "bitcoin.conf" "${COIN_CONF_FILE}"
COPY "scripts/" "${COIN_SCRIPTS}/"

EXPOSE 8332 8333 18332 18333 18443 18444

VOLUME ["${COIN_ROOT_DIR}"]

ENTRYPOINT ["/entrypoint.sh"]

CMD ["bitcoind"]
