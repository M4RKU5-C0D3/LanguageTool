# AGENTS.md

## Project

Docker wrapper for LanguageTool HTTP server. Builds multi-platform images (amd64/arm64) and publishes to `ghcr.io/m4rku5-c0d3/languagetool`.

## Build & Run

```sh
docker compose up --build -d
curl -d "language=en-US" -d "text=a simple test" http://localhost:8081/v2/check
```

Rebuild with fresh snapshot: `docker compose build --no-cache`

## Workflow

- **Commit/push only on explicit user instruction.**
- CI runs daily at 03:00 UTC, on push to `main`, and manually via `workflow_dispatch`.
- Snapshot URL redirects (301) to an internal host. The `ADD` instruction may not follow it reliably; `curl -fsSL` is used instead in the Dockerfile.
- Base image (`eclipse-temurin:17-jre`) lacks the `file` command. Use `unzip -t` for ZIP validation.

## CI Workflow

`.github/workflows/docker-image.yml` builds and pushes to GHCR. Tags: `<snapshot-date>`, `latest`, `sha-<short>`, `main`. Skips if the snapshot date image already exists (override with `force` input).

## Key Files

- `Dockerfile` – image definition
- `docker-entrypoint.sh` – generates `server.properties` if missing, starts Java server
- `compose.yaml` – local dev/test config
