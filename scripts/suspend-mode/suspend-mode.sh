#!/usr/bin/env bash
set -euo pipefail
case "${1:-}" in
  s2idle|deep) echo "$1" > /sys/power/mem_sleep ;;
  *) echo "usage: suspend-mode [s2idle|deep]" >&2; exit 1 ;;
esac
systemctl suspend
