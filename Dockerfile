# syntax=docker/dockerfile:1
#
# LanguageTool embedded HTTP server
# Docs: https://dev.languagetool.org/http-server
#
# Build & run:
#   docker compose up --build -d
#   curl -d "language=en-US" -d "text=a simple test" http://localhost:8081/v2/check

FROM eclipse-temurin:17-jre

ARG SNAPSHOT_URL=https://languagetool.org/download/snapshots/LanguageTool-latest-snapshot.zip

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        curl \
        unzip \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o /tmp/LanguageTool.zip "${SNAPSHOT_URL}" \
    && unzip -t /tmp/LanguageTool.zip >/dev/null 2>&1 \
    && mkdir -p /opt/languagetool/app \
    && unzip -q /tmp/LanguageTool.zip -d /opt/languagetool \
    && rm /tmp/LanguageTool.zip \
    && mv /opt/languagetool/LanguageTool-* /opt/languagetool/app \
    && test -f /opt/languagetool/app/languagetool-server.jar

RUN groupadd --system languagetool \
    && useradd --system --gid languagetool --home-dir /home/languagetool --shell /usr/sbin/nologin languagetool \
    && install -d -o languagetool -g languagetool /home/languagetool /etc/languagetool

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

USER languagetool
WORKDIR /opt/languagetool/app

HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
    CMD curl --fail -s -d "language=en-US" -d "text=a simple test" http://localhost:8081/v2/check || exit 1

EXPOSE 8081

ENTRYPOINT ["docker-entrypoint.sh"]