#!/usr/bin/env bash
# Deploys site/ to Hostinger (vremena.app). Reads creds from project-root .env.
# Never sources .env (Hostinger passwords contain shell metachars) — uses an
# awk extractor, per house rules.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

ENV_FILE="$ROOT/.env"
[[ -f "$ENV_FILE" ]] || { echo "Missing $ENV_FILE"; exit 1; }

ext() { awk -F= -v k="$1" '$1==k{sub(/^[^=]*=/,""); gsub(/^["'"'"']|["'"'"']$/,""); print; exit}' "$ENV_FILE"; }

HOST="$(ext HOSTINGER_SSH_HOST)"
PORT="$(ext HOSTINGER_SSH_PORT)"
USER="$(ext HOSTINGER_SSH_USER)"
PASS="$(ext HOSTINGER_SSH_PASSWORD)"
DEPLOY_PATH="$(ext DEPLOY_PATH)"

[[ -n "$HOST" && -n "$USER" && -n "$PASS" && -n "$DEPLOY_PATH" ]] || { echo "Incomplete creds in .env"; exit 1; }

command -v sshpass >/dev/null || { echo "sshpass required (brew install sshpass)"; exit 1; }

SSH_OPTS=(-o StrictHostKeyChecking=accept-new -o ConnectTimeout=20 -p "$PORT")

echo "==> Removing Hostinger placeholder"
sshpass -p "$PASS" ssh "${SSH_OPTS[@]}" "$USER@$HOST" "rm -f '$DEPLOY_PATH/default.php'"

echo "==> Uploading site/ → $DEPLOY_PATH"
if command -v rsync >/dev/null; then
  sshpass -p "$PASS" rsync -az --delete \
    -e "ssh ${SSH_OPTS[*]}" \
    "$ROOT/site/" "$USER@$HOST:$DEPLOY_PATH/"
else
  sshpass -p "$PASS" scp "${SSH_OPTS[@]}" -r "$ROOT/site/." "$USER@$HOST:$DEPLOY_PATH/"
fi

echo "==> Deployed. Live files:"
sshpass -p "$PASS" ssh "${SSH_OPTS[@]}" "$USER@$HOST" "ls -la '$DEPLOY_PATH'"
echo "==> Done: https://vremena.app"
