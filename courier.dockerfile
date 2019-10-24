FROM debian:stretch-slim

RUN set -ex; \
    addgroup --system courier; \
    adduser --system --ingroup courier courier

# Install ca-certificates so HTTPS works in general
RUN apt-get update && \
  apt-get install -y --no-install-recommends ca-certificates && \
  rm -rf /var/lib/apt/lists/*

ARG COURIER_REPO
ENV COURIER_REPO=${COURIER_REPO:-nyaruka/courier}
ARG COURIER_VERSION
ENV COURIER_VERSION=${COURIER_VERSION:-1.2.84}

RUN set -ex; \
  apt-get update; \
  apt-get install -y --no-install-recommends wget; \
  rm -rf /var/lib/apt/lists/*; \
  \
  wget -O courier.tar.gz "https://github.com/$COURIER_REPO/releases/download/v${COURIER_VERSION}/courier_${COURIER_VERSION}_linux_amd64.tar.gz"; \
  mkdir /usr/local/src/courier; \
  tar -xzC /usr/local/src/courier -f courier.tar.gz; \
  \
# Just grab the binary and ignore the other packaged files
  mv /usr/local/src/courier/courier /usr/local/bin/; \
  rm -rf /usr/local/src/courier courier.tar.gz; \
  \
  apt-get purge -y --auto-remove wget

EXPOSE 8080

USER courier

ENTRYPOINT []
CMD ["courier"]
