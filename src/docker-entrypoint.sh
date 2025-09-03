#!/bin/bash
# Entry point that loads BD_API_TOKEN from Docker secrets if present.
# If /run/secrets/BD_API_TOKEN exists, prefer it over the BD_API_TOKEN env var.
# After loading the secret, exec the scanner script with all passed arguments.

set -euo pipefail

# If a secret file exists, read its contents into BD_API_TOKEN
if [ -f "/run/secrets/BD_API_TOKEN" ]; then
  export BD_API_TOKEN=$(cat /run/secrets/BD_API_TOKEN)
  echo "Loaded BD_API_TOKEN from /run/secrets/BD_API_TOKEN" >&2
fi

# Allow passing a file path to a mounted token as well (convention)
if [ -n "${BD_API_TOKEN_FILE:-}" ] && [ -f "${BD_API_TOKEN_FILE}" ]; then
  export BD_API_TOKEN=$(cat "${BD_API_TOKEN_FILE}")
  echo "Loaded BD_API_TOKEN from path in BD_API_TOKEN_FILE" >&2
fi

# Basic validation: warn if BD_URL or BD_API_TOKEN are empty
if [ -z "${BD_URL:-}" ]; then
  echo "Warning: BD_URL is empty. Set BD_URL via -e or Docker secrets." >&2
fi
if [ -z "${BD_API_TOKEN:-}" ]; then
  echo "Warning: BD_API_TOKEN is empty. Provide it via Docker secret or -e BD_API_TOKEN." >&2
fi

# Exec the scanner script, forwarding args and replacing the shell process.
exec /bin/bash /app/scanlargefolder.sh "$@"
