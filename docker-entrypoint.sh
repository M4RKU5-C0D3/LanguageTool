#!/usr/bin/env bash
set -euo pipefail

CONFIG=/etc/languagetool/server.properties

# Generate a default config only when no custom file is mounted
# (see https://dev.languagetool.org/http-server#TOC-Starting-from-command-line).
if [ ! -s "$CONFIG" ]; then
  cat > "$CONFIG" <<'EOF'
# LanguageTool server configuration
# See: https://dev.languagetool.org/http-server
# Optional fastText settings for better language detection:
#   fasttextModel=/fastText/lid.176.bin
#   fasttextBinary=/usr/local/bin/fasttext
EOF
  [ -n "${FASTTEXT_MODEL:-}" ]  && echo "fasttextModel=${FASTTEXT_MODEL}"  >> "$CONFIG"
  [ -n "${FASTTEXT_BINARY:-}" ] && echo "fasttextBinary=${FASTTEXT_BINARY}" >> "$CONFIG"
fi

args=(
  --config "$CONFIG"
  --port "${PORT:-8081}"
  --allow-origin "${ALLOW_ORIGIN:-*}"
)
[ -n "${LANG_MODEL:-}" ] && args+=(--languageModel "${LANG_MODEL}")

# shellcheck disable=SC2086
exec java ${JAVA_OPTS:-} -cp /opt/languagetool/app/languagetool-server.jar \
  org.languagetool.server.HTTPServer --public "${args[@]}"