# AI

This setup use codex inside a container. Only this repository are visible to AI agent.
This have the advantage to give full-access to agent without security issue.
This setup support customizable AGENTS.md.

## Setup

First thing to do is to build the docker image. Go to `ai/docker` and run `./build.sh`.

## KiCad MCP server

You'll find a submodule under `tools/kimcp` that contain a MCP server implementation
for KiCad.
Container is already setup to try connect to this server.
Start the MCP server before running agents.

## Run

For usage run `ai/run.sh -h`.
Samples AGENTS.md are located in `ai/agents`.
To run with a custom agent : `./ai/run.sh -a ai/agents/kicad_helper.md`.
