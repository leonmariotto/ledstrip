FROM ubuntu:noble

# Install common tools
RUN apt-get update && apt-get install -y wget software-properties-common

# Install KiCad
RUN add-apt-repository --yes ppa:kicad/kicad-9.0-releases \
	&& apt update \
	&& apt install -y --install-recommends kicad

# Install codex CLI
RUN wget https://github.com/openai/codex/releases/download/rust-v0.65.0/codex-x86_64-unknown-linux-gnu.tar.gz \
	&& tar xf codex-x86_64-unknown-linux-gnu.tar.gz \
	&& mv codex-x86_64-unknown-linux-gnu codex

RUN mkdir /workspace

WORKDIR /workspace


