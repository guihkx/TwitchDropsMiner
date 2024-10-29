#!/usr/bin/env bash

if [ -z "${VIRTUAL_ENV}" ]; then
  echo 'Error: Please activate the Python virtual environment first!'
  exit 1
fi

echo -n "Patching python-xlib's unix_connect.py... "

#file_to_patch="$(python -c 'import os; try: import Xlib; except ImportError: print(""); else: print(os.path.join(os.path.dirname(Xlib.__file__), "support", "unix_connect.py"))')"
file_to_patch="$(python -c $'import os; import sys;\ntry: import Xlib;\nexcept ModuleNotFoundError:\n print();\nelse: print(os.path.join(os.path.dirname(Xlib.__file__), "support", "unix_connect.py"))')"

if [ -z "${file_to_patch}" ]; then
  echo 'FAILED!'
  echo 'Error: Unable to import Xlib. Did you forget to run "pip install -r requirements.txt"?'
  exit 1
fi

if [ ! -f "${file_to_patch}" ]; then
  echo 'FAILED!'
  echo "Error: File does not exist in: ${file_to_patch}"
  exit 1
fi

if ! grep -q TMPDIR "${file_to_patch}"; then
  patch="$(
    cat <<EOF
--- unix_connect.py.orig	2024-10-29 01:37:16.857680036 -0300
+++ unix_connect.py	2024-10-29 01:40:38.715143116 -0300
@@ -96,7 +96,7 @@
 
         # Unix socket.
         else:
-            address = '/tmp/.X11-unix/X%d' % dno
+            address = os.environ.get('TMPDIR', '/tmp') + '/.X11-unix/X%d' % dno
             if not os.path.exists(address):
                 # Use abstract address.
                 address = '\0' + address
EOF
  )"

  if ! error="$(patch --binary --quiet --force "${file_to_patch}" <<<"$(sed 's/$/\r/' <<<"${patch}")" 2>&1)"; then
    echo 'FAILED!'
    echo "${error}"
    exit 1
  else
    echo 'OK'
  fi
else
  echo 'SKIPPED (already patched)'
fi

echo -n 'Starting a TigerVNC server at :0 (localhost:5900)... '

if ! error="$(vncserver :0 -geometry 1366x768 -localhost 2>&1)"; then
  echo 'FAILED!'
  echo "${error}"
  echo 'You may stop a running instance with "vncserver -kill :0".'
  exit 1
else
  echo 'OK'
fi

env DISPLAY=:0 python main.py -vvv --log &
echo 'Started TwitchDropsMiner! Use a VNC client to interact with its window.'
pid=$!
waitpid $pid
