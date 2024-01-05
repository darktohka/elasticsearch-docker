ARG VERSION

FROM --platform=$BUILDPLATFORM elasticsearch:${VERSION} AS baseline

ARG VERSION
ARG BRANCH

ENV VERSION=${VERSION}
ENV BRANCH=${BRANCH}

WORKDIR /tmp
COPY clean_image.sh /tmp

RUN ./clean_image.sh

FROM elasticsearch:${VERSION}

ARG VERSION

COPY --from=baseline /tmp/x-pack-core.jar /usr/share/elasticsearch/modules/x-pack-core/x-pack-core-${VERSION}.jar
USER 1000:0
