#!/bin/bash
set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
STATUSLINE_DEST="$CLAUDE_DIR/statusline.sh"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

echo "==> Claude Statusline アンインストーラー"
echo ""

# ── 依存チェック ──────────────────────────────────────────
if ! command -v jq >/dev/null 2>&1; then
    echo "[ERROR] jq が見つかりません。インストールしてから再実行してください。" >&2
    echo "        macOS : brew install jq" >&2
    echo "        Ubuntu: sudo apt install jq" >&2
    echo "        その他: https://jqlang.github.io/jq/download/" >&2
    exit 1
fi

# ── statusline.sh の削除 ──────────────────────────────────
if [ -f "$STATUSLINE_DEST" ]; then
    rm -f "$STATUSLINE_DEST"
    echo "[INFO] 削除しました: $STATUSLINE_DEST"
else
    echo "[INFO] $STATUSLINE_DEST は存在しませんでした (スキップ)"
fi

# ── statusline.sh バックアップの復元確認 ──────────────────
latest_sh_backup=$(ls -1t "$CLAUDE_DIR/statusline.sh.backup."* 2>/dev/null | head -1 || true)
if [ -n "$latest_sh_backup" ]; then
    echo ""
    echo "    バックアップが見つかりました: $latest_sh_backup"
    read -r -p "    このバックアップを復元しますか? [y/N] " restore_sh
    case "${restore_sh:-N}" in
        [yY][eE][sS]|[yY])
            cp "$latest_sh_backup" "$STATUSLINE_DEST"
            chmod +x "$STATUSLINE_DEST"
            echo "[INFO] バックアップを復元しました: $STATUSLINE_DEST"
            ;;
        *)
            echo "[INFO] バックアップの復元をスキップしました"
            ;;
    esac
fi

# ── settings.json から statusLine フィールドを削除 ────────
if [ -f "$SETTINGS_FILE" ] && [ -s "$SETTINGS_FILE" ]; then
    if jq -e . "$SETTINGS_FILE" >/dev/null 2>&1; then
        jq 'del(.statusLine)' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" \
            && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
        echo "[INFO] settings.json から statusLine を削除しました"
    else
        echo "[ERROR] ~/.claude/settings.json が不正な JSON です。手動で statusLine フィールドを削除してください。" >&2
    fi
fi

# ── settings.json バックアップの復元確認 ─────────────────
latest_json_backup=$(ls -1t "$CLAUDE_DIR/settings.json.backup."* 2>/dev/null | head -1 || true)
if [ -n "$latest_json_backup" ]; then
    echo ""
    echo "    settings.json のバックアップが見つかりました: $latest_json_backup"
    read -r -p "    このバックアップを復元しますか? [y/N] " restore_json
    case "${restore_json:-N}" in
        [yY][eE][sS]|[yY])
            cp "$latest_json_backup" "$SETTINGS_FILE"
            echo "[INFO] バックアップを復元しました: $SETTINGS_FILE"
            ;;
        *)
            echo "[INFO] バックアップの復元をスキップしました"
            ;;
    esac
fi

# ── 完了メッセージ ────────────────────────────────────────
echo ""
echo "==> アンインストール完了!"
echo ""
echo "    Claude Code を再起動するとステータスラインが無効になります。"
echo ""
