# syntax=docker/dockerfile:1
#
# LanguageTool embedded HTTP server
# Docs: https://dev.languagetool.org/http-server
#
# Build & run:
#   docker compose up --build -d
#   curl -d "language=en-US" -d "text=a simple test" http://localhost:8081/v2/check

FROM debian:bookworm-slim AS fasttext-build

RUN apt-get update && apt-get install -y --no-install-recommends g++ make wget && rm -rf /var/lib/apt/lists/*
RUN wget -qO- https://github.com/facebookresearch/fastText/archive/v0.9.2.tar.gz | tar xz
RUN cd fastText-0.9.2 && make && cp fasttext /usr/local/bin/fasttext

FROM eclipse-temurin:17-jre

ARG SNAPSHOT_URL=https://languagetool.org/download/snapshots/LanguageTool-latest-snapshot.zip

RUN apt-get update && apt-get install -y --no-install-recommends bash curl unzip
RUN rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o /tmp/LanguageTool.zip "${SNAPSHOT_URL}"
RUN unzip -t /tmp/LanguageTool.zip >/dev/null 2>&1
RUN unzip -q /tmp/LanguageTool.zip -d /opt/languagetool
RUN rm /tmp/LanguageTool.zip
RUN mv /opt/languagetool/LanguageTool-* /opt/languagetool/app
RUN test -f /opt/languagetool/app/languagetool-server.jar

RUN groupadd --system languagetool
RUN useradd --system --gid languagetool --home-dir /home/languagetool --shell /usr/sbin/nologin languagetool
RUN install -d -o languagetool -g languagetool /home/languagetool /etc/languagetool

COPY --from=fasttext-build /usr/local/bin/fasttext /usr/local/bin/fasttext

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

USER languagetool
WORKDIR /opt/languagetool/app

HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
    CMD curl --fail -s -d "language=en-US" -d "text=a simple test" http://localhost:8081/v2/check || exit 1

EXPOSE 8081

ENTRYPOINT ["docker-entrypoint.sh"]