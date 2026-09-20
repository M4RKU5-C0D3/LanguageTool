# LanguageTool Docker

LanguageTool as a local HTTP server in a Docker container – based on the official
documentation: <https://dev.languagetool.org/http-server>

**Note:** The image uses an official LanguageTool **snapshot**
(`LanguageTool-latest-snapshot.zip`). AI-based rules are only available in the
cloud service.

## Getting started

```sh
docker compose up --build -d
```

The server is then available at `http://localhost:8081`.

## Test

```sh
curl -d "language=en-US" -d "text=a simple test" http://localhost:8081/v2/check
```

Directly in the browser:

```
http://localhost:8081/v2/check?language=en-US&text=my+text
```

## Configuration

The following variables can be set in `compose.yaml` under `environment`:

| Variable          | Default | Description                                              |
|-------------------|---------|----------------------------------------------------------|
| `JAVA_OPTS`       | `-Xmx1g`| JVM options, e.g. heap size                              |
| `PORT`            | `8081`  | HTTP port of the server                                  |
| `ALLOW_ORIGIN`    | `*`     | Allowed origin for the browser add-on                    |
| `FASTTEXT_MODEL`  | –       | Path to the fastText model (`lid.176.bin`)               |
| `FASTTEXT_BINARY` | –       | Path to the fastText binary                              |
| `LANG_MODEL`      | –       | Directory with ngram data (`--langmodel`)                |

### Optional: fastText (language detection)

For good language detection the docs recommend fastText. Mount the model and
binary into a volume and set the variables:

```yaml
environment:
  FASTTEXT_MODEL: /fastText/lid.176.bin
  FASTTEXT_BINARY: /usr/local/bin/fasttext
volumes:
  - ./fasttext/lid.176.bin:/fastText/lid.176.bin:ro
```

Download the model with:

```sh
mkdir -p fasttext
wget https://dl.fbaipublicfiles.com/fasttext/supervised-models/lid.176.bin -O fasttext/lid.176.bin
```

### Optional: ngram data

```yaml
environment:
  LANG_MODEL: /models
volumes:
  - ./ngrams:/models:ro
```

ngram data is available at <https://languagetool.org/download/ngram-data/>.

### Optional: custom `server.properties`

Mount your own file (see <https://dev.languagetool.org/http-server>):

```yaml
volumes:
  - ./server.properties:/etc/languagetool/server.properties:ro
```

The container only generates a default `server.properties` when no file is
mounted.

## External access

By default the port is only published on `127.0.0.1`. For LAN access change the
entry in `ports`:

```yaml
ports:
  - "0.0.0.0:8081:8081"
```

## Rebuilding the image

The snapshot version is re-downloaded on `docker compose build`:

```sh
docker compose build --no-cache
```

## Disclaimer

This is a personal project. It only uses the official public LanguageTool
snapshots from <https://languagetool.org/download/snapshots/> and is not
affiliated with or endorsed by the LanguageTool team.

## Vibe coding

This project was built with AI assistance via [opencode](https://opencode.ai)
using the model `big-pickle`. All code was reviewed and released by a human
maintainer.

## Files

- `Dockerfile` – image definition (Temurin JRE 17, snapshot ZIP)
- `docker-entrypoint.sh` – start script, generates `server.properties`
- `compose.yaml` – compose configuration