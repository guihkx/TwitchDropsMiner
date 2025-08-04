#!/usr/bin/env sh

set -x
#Xvfb "${DISPLAY}" -screen 0 1366x768x24 -nolisten tcp &
Xvnc "${DISPLAY}" -alwaysshared -depth 24 -geometry 1366x768 -localhost -rfbport "${VNC_PORT}" -SecurityTypes None 2>/dev/null &
{ set +x; } 2>/dev/null

while [ ! -e "/tmp/.X11-unix/X${DISPLAY#:}" ]; do
  sleep 0.5
done

cat <<EOF > ~/.jwmrc
<?xml version="1.0"?>
<JWM>
  <Desktops width="1" height="1"/>
  <Group>
    <Name>twitch.*</Name>
    <Option>centered</Option>
    <Option>constrain</Option>
  </Group>
  <Tray x="0" y="-1" height="24">
    <TaskList/>
    <Clock format="%H:%M"/>
  </Tray>
  <RootMenu onroot="123">
    <Restart label"Reload JWM"/>
  </RootMenu>
</JWM>
EOF

set -x
jwm &

#x11vnc -quiet -nopw -forever -shared -localhost -rfbport "${VNC_PORT}" >/dev/null 2>&1 &
{ set +x; } 2>/dev/null

while ! grep -Fq ":$(printf '%04X' "${VNC_PORT}") " /proc/net/tcp; do
  sleep 0.5
done

set -x
"${@}"
