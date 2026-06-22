FROM debian:trixie-slim

# texlive-full already pulls latexmk + biber; listed explicitly so intent is clear.
RUN apt-get update && apt-get install -y --no-install-recommends \
        texlive-full \
        latexmk \
        biber \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /data
ENTRYPOINT ["latexmk"]
