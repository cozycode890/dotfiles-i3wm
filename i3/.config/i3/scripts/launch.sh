#!/usr/bin/env bash
# Terminate already running bar instances
killall -q xwinwrap

# Wait until the processes have been shut down
while pgrep -u $UID -x xwinwrap >/dev/null; do sleep 5; done

# Launch the bar
xwinwrap -b -ni -nf -ov -g 1920x1080+0+0 -- \
  mpv --wid=%WID --loop --no-audio --no-osd-bar --panscan=1.0 \
  --no-border ~/Videos/wallpaper-new.mp4
