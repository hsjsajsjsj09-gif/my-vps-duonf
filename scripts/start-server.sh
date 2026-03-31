#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVER_DIR="$ROOT_DIR/server"
ENV_FILE="$ROOT_DIR/.env"

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

MC_VERSION="${MC_VERSION:-1.20.6}"
PAPER_BUILD="${PAPER_BUILD:-151}"
MEMORY="${MEMORY:-2G}"
PAPER_JAR="paper-${MC_VERSION}-${PAPER_BUILD}.jar"
PAPER_URL="https://api.papermc.io/v2/projects/paper/versions/${MC_VERSION}/builds/${PAPER_BUILD}/downloads/${PAPER_JAR}"

mkdir -p "$SERVER_DIR"
cd "$SERVER_DIR"

if [[ ! -f "eula.txt" ]]; then
  echo "eula=true" > eula.txt
  echo "[INFO] Đã tạo eula.txt với eula=true"
fi

if [[ ! -f "$PAPER_JAR" ]]; then
  echo "[INFO] Đang tải PaperMC: $PAPER_JAR"
  curl -fL "$PAPER_URL" -o "$PAPER_JAR"
fi

echo "[INFO] Khởi động server với RAM $MEMORY"
exec java -Xms1G -Xmx"$MEMORY" -jar "$PAPER_JAR" --nogui
