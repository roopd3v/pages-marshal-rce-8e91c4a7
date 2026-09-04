#!/bin/sh
set -eu

# Safe, single-target Pages boundary probe. The hostname is GitHub's published
# SSRF test target. Do not replace it with another internal host.
target_host="ssrf-target.iad.github.net"
result_file="/github/workspace/PAGES_INTERNAL_BOUNDARY_PROBE.txt"
body_file="/tmp/pages-boundary-response.body"

dns_resolved=false
if getent hosts "$target_host" >/dev/null 2>&1; then
  dns_resolved=true
fi

http_code="000"
if command -v curl >/dev/null 2>&1; then
  http_code="$(curl --silent --show-error --location \
    --connect-timeout 3 --max-time 5 \
    --output "$body_file" --write-out '%{http_code}' \
    "http://$target_host/" || true)"
elif command -v wget >/dev/null 2>&1; then
  if wget --quiet --timeout=5 --tries=1 --output-document="$body_file" \
    "http://$target_host/"; then
    http_code="200"
  fi
fi

if [ -f "$body_file" ]; then
  body_bytes="$(wc -c < "$body_file" | tr -d ' ')"
  body_sha256="$(sha256sum "$body_file" | awk '{print $1}')"
else
  body_bytes="0"
  body_sha256="none"
fi

{
  printf 'target=%s\n' "$target_host"
  printf 'dns_resolved=%s\n' "$dns_resolved"
  printf 'http_code=%s\n' "$http_code"
  printf 'body_bytes=%s\n' "$body_bytes"
  printf 'body_sha256=%s\n' "$body_sha256"
  printf 'body_retained=false\n'
} > "$result_file"

rm -f "$body_file"

