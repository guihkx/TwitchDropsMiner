#!/bin/bash

set -e

set -x
# Start X virtual framebuffer
Xvfb "${DISPLAY}" -screen 0 1366x768x24 -nolisten tcp &
{ set +x; } 2>/dev/null

while [ ! -e "/tmp/.X11-unix/X${DISPLAY#:}" ]; do
  sleep 0.5
done

set -x
jwm -f /dev/null 2>/dev/null &

x11vnc \
  -quiet \
  -nopw \
  -forever \
  -shared \
  -localhost \
  -rfbport "${VNC_PORT}" &>/dev/null &
{ set +x; } 2>/dev/null

while ! grep -Fq ":$(printf '%04X' "${VNC_PORT}") " /proc/net/tcp; do
  sleep 0.5
done

# Execute CMDs
set -x
"$@"
