#!/bin/bash

#Notifications and statusbar
killall dwmblocks
dwmblocks &

#Nice Ones
eww daemon &

#Apps
setxkbmap -layout us,ru -option 'grp:alt_shift_toggle,grp_led:scroll' &
nitrogen --restore &
xsetroot -cursor_name left_ptr &
greenclip daemon &
/usr/lib/xfce-polkit/xfce-polkit &
xfce4-power-manager &
xset r rate 300 47 &

#Monitor settings
xrandr --output HDMI-0 --mode 1920x1080 -r 75 --pos 0x180 --rotate normal --output DP-4 --primary --mode 1920x1080 -r 144 --pos 1440x0 --rotate normal &