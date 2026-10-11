#!/bin/sh
set -eu

AGENT_DIR="/home/node/.pi/agent"
PLUGIN='npm:pi-provider-newapi'
MARKER="$AGENT_DIR/.docker-newapi-plugin-installed"

case "$PUID:$PGID" in
    *[!0-9:]*|:*|*:) echo '[Pi] Invalid PUID/PGID' >&2; exit 1 ;;
esac

mkdir -p "$AGENT_DIR"
chown "$PUID:$PGID" /home/node /home/node/.pi
find "$AGENT_DIR" -xdev \( ! -uid "$PUID" -o ! -gid "$PGID" \) \
    -exec chown -h "$PUID:$PGID" {} +

# Plugin installation and Pi itself run as the caller's UID/GID.
if [ ! -f "$MARKER" ]; then
    echo '[Pi] Initial installation of pi-provider-newapi...'
    setpriv --reuid "$PUID" --regid "$PGID" --groups "$PI_GROUPS" \
        pi install "$PLUGIN"
    setpriv --reuid "$PUID" --regid "$PGID" --groups "$PI_GROUPS" \
        touch "$MARKER"
fi

exec setpriv --reuid "$PUID" --regid "$PGID" --groups "$PI_GROUPS" pi "$@"
