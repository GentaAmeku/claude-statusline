# claude-statusline

A custom statusline for Claude Code that displays model name, context usage, rate limits, session duration, and more.

![screenshot](./assets/screenshot.png)

---

## Installation

### One-liner

```bash
curl -fsSL https://raw.githubusercontent.com/GentaAmeku/claude-statusline/main/install.sh | bash
```

### Manual Installation

```bash
git clone https://github.com/GentaAmeku/claude-statusline.git
cd claude-statusline
bash install.sh
```

After installation, **restart Claude Code**.

---

## Uninstallation

### One-liner

```bash
curl -fsSL https://raw.githubusercontent.com/GentaAmeku/claude-statusline/main/uninstall.sh | bash
```

### Manual

```bash
bash uninstall.sh
```

---

## Requirements

| Command | Required     | Purpose                             |
| ------- | ------------ | ----------------------------------- |
| `jq`    | **Required** | Merging / editing settings.json     |
| `curl`  | Recommended  | Required for one-liner installation |
| `git`   | Optional     | Version control                     |

Install `jq` before running the installer:

```bash
# macOS
brew install jq

# Ubuntu / Debian
sudo apt install jq

# Others
# https://jqlang.github.io/jq/download/
```

---

## Customization

After installation, edit `~/.claude/statusline.sh` directly to customize what the statusline displays.

---

## License

MIT License — see [LICENSE](./LICENSE) for details.
