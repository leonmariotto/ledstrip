from ubuntu:noble

RUN apt-get install -y kicad wget

# Install codex CLI
RUN wget wget https://github.com/openai/codex/releases/download/rust-v0.65.0/codex-x86_64-unknown-linux-gnu.tar.gz \
	&& tar xf codex-x86_64-unknown-linux-gnu.tar.gz \
	&& mv codex-x86_64-unknown-linux-gnu codex

RUN mkdir /workspace

WORKDIR /workspace

