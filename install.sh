#!/bin/bash
set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
STATUSLINE_DEST="$CLAUDE_DIR/statusline.sh"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
RAW_URL="${RAW_URL:-https://raw.githubusercontent.com/GentaAmeku/claude-statusline/main/statusline.sh}"

echo "==> Claude Statusline インストーラー"
echo ""

# ── 依存チェック ──────────────────────────────────────────
check_dep() {
    local cmd="$1" level="$2" msg="$3"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "[WARNING] $cmd が見つかりません。$msg"
        [ "$level" = "required" ] && return 1
    fi
    return 0
}

check_dep curl   optional "curl がない場合、ローカルファイルからのコピーのみ使用されます。"
check_dep git    optional "git は省略可能ですが、バージョン管理のために推奨します。"

if ! command -v jq >/dev/null 2>&1; then
    echo "[ERROR] jq が見つかりません。インストールしてから再実行してください。" >&2
    echo "        macOS : brew install jq" >&2
    echo "        Ubuntu: sudo apt install jq" >&2
    echo "        その他: https://jqlang.github.io/jq/download/" >&2
    exit 1
fi

# ── ~/.claude ディレクトリ確保 ────────────────────────────
mkdir -p "$CLAUDE_DIR"

# ── バックアップ ──────────────────────────────────────────
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

if [ -f "$STATUSLINE_DEST" ]; then
    backup="$STATUSLINE_DEST.backup.$TIMESTAMP"
    cp "$STATUSLINE_DEST" "$backup"
    echo "[INFO] 既存の statusline.sh をバックアップしました: $backup"
fi

if [ -f "$SETTINGS_FILE" ]; then
    backup="$SETTINGS_FILE.backup.$TIMESTAMP"
    cp "$SETTINGS_FILE" "$backup"
    echo "[INFO] 既存の settings.json をバックアップしました: $backup"
fi

# ── statusline.sh の配置 ──────────────────────────────────
LOCAL_SH=""
if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/statusline.sh" ]; then
    LOCAL_SH="$SCRIPT_DIR/statusline.sh"
fi

if [ -n "$LOCAL_SH" ]; then
    cp "$LOCAL_SH" "$STATUSLINE_DEST"
    echo "[INFO] statusline.sh をコピーしました (ローカル)"
else
    echo "[INFO] ローカルファイルが見つからないため、リモートからダウンロードします..."
    if ! command -v curl >/dev/null 2>&1; then
        echo "[ERROR] curl が必要ですが見つかりません。手動でインストールしてください。" >&2
        exit 1
    fi
    curl -fsSL "$RAW_URL" -o "$STATUSLINE_DEST"
    echo "[INFO] statusline.sh をダウンロードしました"
fi

chmod +x "$STATUSLINE_DEST"
echo "[INFO] 実行権限を付与しました: $STATUSLINE_DEST"

# ── settings.json の statusLine マージ ───────────────────
STATUS_LINE_JSON='{
  "type": "command",
  "command": "~/.claude/statusline.sh",
  "padding": 0
}'

if [ ! -f "$SETTINGS_FILE" ] || [ ! -s "$SETTINGS_FILE" ]; then
    echo "$STATUS_LINE_JSON" | jq '{statusLine: .}' > "$SETTINGS_FILE"
    echo "[INFO] settings.json を新規作成しました"
elif jq -e . "$SETTINGS_FILE" >/dev/null 2>&1; then
    jq --argjson sl "$STATUS_LINE_JSON" '.statusLine = $sl' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" \
        && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
    echo "[INFO] settings.json を更新しました"
else
    echo "[ERROR] ~/.claude/settings.json が不正な JSON です。修正してから再実行してください。" >&2
    exit 1
fi

# ── 完了メッセージ ────────────────────────────────────────
echo ""
echo "==> インストール完了!"
echo ""
echo "    インストール先: $STATUSLINE_DEST"
echo "    設定ファイル  : $SETTINGS_FILE"
echo ""
echo "    Claude Code を再起動するとステータスラインが有効になります。"
echo ""
