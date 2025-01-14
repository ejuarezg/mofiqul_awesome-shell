#!/bin/bash
# Screen recording script
# Author: elenapan @ github
# Requires ffmpeg
# Info: https://trac.ffmpeg.org/wiki/Capture/Desktop
# --------------------------------------------
# This directory will be created automatically if it does not exist
if [ -z "$1" ]; then
    RECORDINGS_DIR="$HOME/Videos/Recordings"
else
    RECORDINGS_DIR="$(dirname "$1")"
    BASENAME="$(basename "$1")"
fi
# --- Resolution ---
# >> Manually
# SCREEN_RESOLUTION=1920x1080
# >> Automatically
# Sauce: https://superuser.com/questions/196532/how-do-i-find-out-my-screen-resolution-from-a-shell-script
SCREEN_RESOLUTION="$(xrandr --current -q | sed -n 's/.* connected \([0-9]*\)x\([0-9]*\)+.*/\1x\2/p')"
# >> TODO select area to record with `slop`
# --- Audio ---
# Comment out both if you want to disable sound
# >> Pulse
AUDIO=" -f pulse -ac 2 -i default "
# >> Alsa
# AUDIO=" f alsa -ac 2 -i hw:0 "

# Notification icon path
REC_ICON_PATH="$HOME/.config/awesome/themes/default/icons/48x48/camera-on.svg"
# --------------------------------------------

# Create directory if needed
if [ ! -d "$RECORDINGS_DIR" ]; then
    mkdir -p "$RECORDINGS_DIR"
fi

# Search for screen recording process
pid="$(ps -o pid,command ax | grep "ffmpeg" | grep "x11grab" | awk '{print $1}')"
if [ -z "$pid" ]; then
    TIMESTAMP="$(date +%Y.%m.%d-%H.%M.%S)"
    FILENAME="$RECORDINGS_DIR/${BASENAME:-$TIMESTAMP.screenrec.mp4}"

    if [ -z "$2" ]; then
        notify-send "Screen is being recorded." --urgency low -i $REC_ICON_PATH
    fi

    # --- Hardware decoding (for NVIDIA GPU) ---
    # Needs ffmpeg compiled with --enable-nvenc
    # ffmpeg $AUDIO -s $SCREEN_RESOLUTION -f x11grab -i :0.0 -c:v h264_nvenc -profile high444p -pixel_format yuv444p -preset default $FILENAME

    # --- Software decoding ---
    # ffmpeg -f x11grab -s $SCREEN_RESOLUTION -i :0.0 -vcodec libx264 -preset medium -crf 22 -y $FILENAME

    # --- Hardware decoding (for Intel integrated graphics) ---
    ffmpeg -vaapi_device /dev/dri/renderD128 -f x11grab -video_size $SCREEN_RESOLUTION -framerate 15 -i :0 -vf "format=nv12,hwupload" -c:v h264_vaapi -qp 24 -y $FILENAME

    if [ -z "$2" ]; then
        notify-send "Screen recording over." --urgency low -i $REC_ICON_PATH
    fi
else
    # Stop recording
    kill $pid
fi
