#!/usr/bin/env bash

set -o pipefail

filename="$(realpath "$1")"
size_x=$2
size_y=$3
pos_x=$4
pos_y=$5

no_cache=0
#old_preview_file=/tmp/lfoldpreview.pid
#old_preview_pid="$(cat "$old_preview_file")"
#kill -KILL "$old_preview_pid" &
#echo "$$" >"$old_preview_file"

chafa_wrapper() {
  chafa \
    --format sixel \
    --polite on \
    --passthrough none \
    --colors full \
    --optimize 9 \
    --animate off \
    --size "${size_x}x$((size_y - 2))" \
    "$@"
}

image_preview() {
  bytes="$(stat -c '%s' "$filename")"
  if [ "$bytes" -gt "$((1024 * 1024 * 10))" ]; then # 10 megs
    printf "file too big: disabling image preview\n\n" | fold -w "$size_x"
    magick identify -ping \
      -format '%m %wx%h, %[colorspace], %r' \
      "$filename" 2>&1 | fold -w "$size_x" && success="yes"
  else
    if chafa_wrapper "$filename"; then
      success="yes"
      no_cache=1
    fi
    # display additional info at the bottom
    tput cuf "$pos_x"
    magick identify -ping \
      -format '%m %wx%h, %[colorspace], %r' \
      "$filename" | head -c "$size_x"
  fi
}

video_preview() {
  IFS=',' read -r w h fps len codec < <(mediainfo --Inform="Video;%Width%,%Height%,%FrameRate%,%Duration%,%CodecID%" "$filename")
  len="${len%.*}" # remove everything after dot
  len="${len:-0}" # fallback
  pos=2 # 2 means 1/2

  if ffmpeg \
    -ss "$((len / pos))ms" \
    -i "$filename" \
    -vf "scale='min(640,iw)':'min(480,ih)':force_original_aspect_ratio=decrease" \
    -vframes 1 \
    -f apng pipe:1 | chafa_wrapper;
  then
    success="yes"
    no_cache=1
  fi

  # display additional info at the bottom
  tput cuf "$pos_x"
  # covert seconds to hh:mm:ss
  total_sec="$((len / 1000))"
  sec="$((total_sec % 60))"
  min="$(((total_sec / 60) % 60))"
  hr="$((total_sec / 3600))"
  time_string="$([ "$hr" -gt 0 ] && printf "%dh" "$hr")$([ "$min" -gt 0 ] && printf "%dm" "$min")${sec}s"
  printf '%s, %dx%d, %s fps, %s' "$time_string" "$w" "$h" "$fps" "$codec" | head -c "$size_x"
}

pdf_preview() {
  if magick \
    "${filename}[0]" \
    -background '#FFFFFF' \
    -alpha deactivate \
    jpg:- | chafa_wrapper;
  then
    success="yes"
    no_cache=1
  fi
}

audio_preview() {
  mediainfo "$filename" | \
    awk -F '( +):' '{ gsub(/( +)$/, "", $1); print $1 ($2 ? ":" : "") $2 }' && success="yes"
}

archive_preview() {
  bsdtar -tf "$filename" && success="yes"
}

json_preview() {
  #if command -v bat >/dev/null 2>&1; then
  #  bat \
  #    --wrap character \
  #    --terminal-width "$size_x" \
  #    --language json \
  #    "$filename" && success="yes"
  #else
  #  jq --color-output '.' "$filename" && success="yes"
  #fi
  text_preview
}

text_preview() {
    awk -v w="$size_x" -v h="$size_y" \
        '{print substr($0, 0, w)} (NR >= h) {exit}' \
        "$filename" && success="yes"
}

fallback_preview() {
  file --brief "$filename" | fold -s -w "$size_x"
  printf '\n%s\n' "$mime_description"
}

extension="${filename##*.}"
case "$extension" in
  txt|cfg|conf|properties|log|ini|yaml|toml|py|c|cpp|h|hpp|rs|zig|js|ts|nix|json)
    text_preview;;
  jxl|png|jpeg|jpg|webp|gif)
    image_preview;;
  mkv|mp4|webm)
    video_preview;;
  pdf)
    pdf_preview;;
  flac|wav|mp3|opus|ape)
    audio_preview;;
  tar|gz|xz|zst|bz2|zstd|tgz|txz|tzst|tzstd|tbz2|zip|rar|jar)
    archive_preview;;
esac

if [ -z "$success" ]; then
  mime_description=$(file --brief --mime -- "$filename")
  case "$mime_description" in
    image/*)
      image_preview;;
    video/*)
      video_preview;;
    application/pdf*)
      pdf_preview;;
    audio/*)
      audio_preview;;
    application/x-tar*|application/zstd*|application/gzip*|application/x-xz*|application/zip*|application/java-archive*|application/x-7z*|application/x-rar*|application/x-bzip2*)
      archive_preview;;
    application/json*)
      json_preview;;
  esac
fi

if [ -z "$success" ] && [[ "$mime_description" =~ charset= ]] && [[ ! "$mime_description" =~ charset=binary ]]; then
  text_preview
fi

if [ -z "$success" ]; then
  fallback_preview
fi

#exit $no_cache
exit 0 # if lf uses 500mb of ram uncomment line above

