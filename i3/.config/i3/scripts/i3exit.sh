#!/bin/sh

case "$1" in
lock)
  light-locker-command -l
  ;;
logout)
  i3-msg exit
  ;;
suspend)
  systemctl suspend
  ;;
hibernate)
  systemctl hibernate
  ;;
reboot)
  systemctl reboot
  ;;
shutdown)
  shutdown now
  ;;
*)
  echo "Usage: $0 {lock|logout|suspend|hibernate|reboot|shutdown}"
  exit 2
  ;;
esac

exit 0
