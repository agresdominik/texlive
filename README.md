# texlive

A "batteries-included" LaTeX toolchain in a Docker image: `texlive-full` +
`latexmk` + `biber` on `debian:trixie-slim`. Built for academic writing —
heavy math, `biblatex`/`biber`, TikZ/pgfplots, German `babel` + `fontspec`.

Multi-arch: `linux/amd64` and `linux/arm64`, so it runs natively on an Asahi
Mac (arm64) and an Arch desktop (amd64) alike.

```
ghcr.io/agresdominik/texlive:latest
```

## Pull

```sh
docker pull ghcr.io/agresdominik/texlive:latest
```

Docker picks the right arch from the manifest automatically.

## Use

The image's entrypoint is `latexmk` with `WORKDIR /data`, so anything after
the image name is passed straight to `latexmk`.

### `tex` wrapper

Mounts the current directory into the container and fixes file ownership so
output isn't root-owned (`--user` + a writable `HOME` for TeX's cache).

zsh function — drop into `~/.zshrc`:

```zsh
tex() {
  docker run --rm \
    --user "$(id -u):$(id -g)" \
    -e HOME=/tmp \
    -v "$PWD:/data" \
    ghcr.io/agresdominik/texlive:latest "$@"
}
```

Or use the standalone [`tex`](./tex) script — put it on your `$PATH`:

```sh
install -m755 tex ~/.local/bin/tex
```

Then:

```sh
tex -pdf main.tex      # build
tex -pvc main.tex      # watch + rebuild
tex -C                 # clean aux files
```

## How the multi-arch build works

`.github/workflows/build.yml` builds **natively per arch** — no QEMU:

1. A matrix `build` job runs once on `ubuntu-24.04` (amd64) and once on
   `ubuntu-24.04-arm` (arm64). Each builds for its own platform and pushes a
   per-arch tag: `:<sha>-amd64`, `:<sha>-arm64`.
2. A final `manifest` job merges those into single multi-arch tags with
   `docker buildx imagetools create`, publishing both `:latest` and `:<sha>`.

Auth is `GITHUB_TOKEN` with `packages: write`, logging in to `ghcr.io`.
Triggers: push to `main` and manual `workflow_dispatch`.

## Trimming the image later

`texlive-full` is large (multiple GB). If size becomes a problem, swap the
Debian package for a custom TeX Live install driven by a `texlive.profile`,
selecting `scheme-full` down to e.g. `scheme-medium` plus only the collections
you need (`collection-latexextra`, `collection-bibtexextra`,
`collection-pictures`, `collection-langgerman`, `collection-fontsrecommended`,
…). Build with `install-tl --profile texlive.profile`, then `tlmgr install`
any stragglers. Keep `scheme-full` until the size actually hurts.

## License

MIT — see [LICENSE](./LICENSE).
