# ocgo2cli

Anthropic Messages API → OpenAI Chat Completions proxy with strict 1:1 model mapping. Designed for [Claude Code](https://github.com/anthropics/claude-code) to route model requests through OpenCode Go backends.

## What It Does

Claude Code speaks Anthropic Messages API, but your backend may speak OpenAI Chat Completions. ocgo2cli sits in between and translates:

```
Claude Code                    ocgo2cli                     OpenCode Go
   │                              │                              │
   │  POST /v1/messages           │                              │
   │  {"model":"claude-sonnet-4"} │                              │
   │ ──────────────────────────►  │                              │
   │                              │  POST /v1/chat/completions   │
   │                              │  {"model":"deepseek-v4-pro"} │
   │                              │ ───────────────────────────► │
   │                              │                              │
   │                              │  ◄─────────────────────────  │
   │  ◄────────────────────────── │                              │
```

**No scenario detection, no fallback chains, no mid-conversation model switching.** Just a config-driven 1:1 model map.

## Features

- **Strict 1:1 model mapping** — Claude model names map directly to backend model IDs via JSON config
- **Format conversion** — Anthropic Messages API ↔ OpenAI Chat Completions with full type fidelity
- **Anthropic-native bypass** — MiniMax M2.5/M2.7 pass through without conversion
- **Thinking/reasoning support** — Full `thinking` ↔ `reasoning_content` roundtrip for DeepSeek
- **SSE streaming** — Real-time streaming with proper block transitions
- **Daemon mode** — Cross-platform background service (Linux systemd, macOS launchd, Windows SCM)
- **Environment variable interpolation** — `${VAR}` in config values

## Quick Start

### Install

```bash
git clone git@github.com:SurgeSeeker/ocgo2cli.git
cd ocgo2cli
make build
```

### Configure

Create `~/.config/ocgo2cli/config.json`:

```json
{
  "listen_addr": "127.0.0.1:3457",
  "models": {
    "claude-sonnet-4-20250514": {
      "model_id": "deepseek-v4-pro",
      "api_key": "${OC_API_KEY}",
      "base_url": "https://api.example.com/v1"
    }
  }
}
```

### Run

```bash
# Foreground (for debugging)
ocgo2cli run

# Daemon
ocgo2cli start
ocgo2cli status
ocgo2cli stop
```

### Use with Claude Code

Configure Claude Code to use ocgo2cli as its Anthropic API endpoint:

```json
// ~/.claude/settings.json
{
  "env": {
    "ANTHROPIC_BASE_URL": "http://127.0.0.1:3457"
  }
}
```

## Configuration Reference

| Field | Description |
|-------|-------------|
| `listen_addr` | HTTP listen address (default: `127.0.0.1:3457`) |
| `models.<name>.model_id` | Backend model ID to route to |
| `models.<name>.api_key` | API key (supports `${ENV}` interpolation) |
| `models.<name>.base_url` | Backend base URL |
| `models.<name>.temperature` | Override temperature |
| `models.<name>.max_tokens` | Override max tokens |
| `models.<name>.reasoning_effort` | Reasoning effort for supported models |
| `models.<name>.thinking` | Thinking mode override (`enabled`/`disabled`/`auto`) |

## Daemon Management

```bash
ocgo2cli start                # Start as daemon
ocgo2cli stop                 # Stop daemon
ocgo2cli restart              # Restart
ocgo2cli status               # Query status
ocgo2cli run                  # Run in foreground
ocgo2cli install              # Install as user-level service
ocgo2cli uninstall            # Remove service
ocgo2cli version              # Print version
```

No root/sudo required. Installs as a user-level service.

## Build & Test

```bash
make build    # Build binary to bin/ocgo2cli
make test     # Run tests with race detector
make lint     # go vet
make clean    # Remove build artifacts
```

## Architecture

```
main.go         — HTTP server, handler, model routing, daemon CLI
config.go       — JSON config loader with ${ENV} interpolation
transformer.go  — Anthropic ↔ OpenAI format conversion
types.go        — Anthropic + OpenAI type definitions
sse.go          — Streaming SSE transformation
```

~1,400 lines, 5 files, standard library + [kardianos/service](https://github.com/kardianos/service) for daemon.

## Credits

This project's format conversion logic is based on [oc-go-cc](https://github.com/nousresearch/oc-go-cc) by Nous Research — the reference implementation for Anthropic ↔ OpenAI message translation.

## License

GNU Affero General Public License v3.0 — see [LICENSE](LICENSE).
