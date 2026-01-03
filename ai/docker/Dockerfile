FROM ubuntu:noble

# Install common tools
RUN apt-get update \
	&& apt-get install -y wget software-properties-common curl poppler-utils

# Install KiCad
RUN add-apt-repository --yes ppa:kicad/kicad-9.0-releases \
	&& apt-get update \
	&& apt-get install -y --install-recommends kicad

# Install ripgrep
RUN wget https://github.com/BurntSushi/ripgrep/releases/download/15.1.0/ripgrep_15.1.0-1_amd64.deb
RUN apt install ./ripgrep_15.1.0-1_amd64.deb

# Install codex CLI
RUN wget https://github.com/openai/codex/releases/download/rust-v0.65.0/codex-x86_64-unknown-linux-gnu.tar.gz \
	&& tar xf codex-x86_64-unknown-linux-gnu.tar.gz \
	&& mv codex-x86_64-unknown-linux-gnu codex

# Install codex config
RUN mkdir /root/.codex
COPY codex_config.toml /root/.codex/config.toml

RUN mkdir /workspace

WORKDIR /workspace


