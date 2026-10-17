#!/bin/bash
export SDL_VIDEODRIVER=kmsdrm
cd ~
sel=1
HITBOX_FILE=~/.touhou_hitbox
[ -f "$HITBOX_FILE" ] || echo off > "$HITBOX_FILE"
draw() {
  hitbox=$(cat "$HITBOX_FILE")
  options=("TH06 EoSD" "TH06 EoSD+ (eagler)" "TH07 PCB" "TH07 PCB+ (eagler)" "TH08 IN+ (eagler-native)" "TH09 PoFV+ (eagler-native)" "TH10 MoF+ (eagler-native)" "TH11 SA+ (eagler-native)" "TH15 LoLK+ (eagler-native)" "PC-98 TH01-05" "Hitbox Mode: $hitbox" "Video Player" "Exit to Console" "Reboot" "Power Off")
  clear
  echo "========= TOUHOU PLAYER ========="
  for i in "${!options[@]}"; do
    if [ "$((i+1))" = "$sel" ]; then echo "  > ${options[$i]} <"; else echo "    ${options[$i]}"; fi
  done
  echo "---------------------------------"
  echo " UP/DOWN: select   Z: OK / cycle"
  echo " Hitbox mode affects the eagler (+) versions"
  echo " Fn+UP/DOWN/L/R/ESC: F1-F5 (PC-98 menu)"
}
while true; do
  draw
  IFS= read -rsn1 k
  if [[ $k == $'\x1b' ]]; then
    read -rsn2 -t 0.1 k2
    case $k2 in
      '[A') [ $sel -gt 1 ] && sel=$((sel-1));;
      '[B') [ $sel -lt 15 ] && sel=$((sel+1));;
    esac
  elif [[ $k == 'z' || $k == '' ]]; then
    hitbox=$(cat "$HITBOX_FILE")
    case $sel in
      1) (cd ~/games/th06 && ./th06);;
      2) (cd ~/games/th06 && TH_HITBOX=$hitbox ./th06e);;
      3) (cd ~/games/th07 && ./th07);;
      4) (cd ~/games/th07 && TH_HITBOX=$hitbox ./th07e);;
      5) sudo ln -sfn ~/games/th08 /game && (cd ~/games/th08 && TH_HITBOX=$hitbox ./th08e);;
      6) (cd ~/games/th09 && TH_HITBOX=$hitbox ./th09e);;
      7) (cd ~/games/th10 && TH_HITBOX=$hitbox ./th10e);;
      8) (cd ~/games/th11 && TH_HITBOX=$hitbox ./th11e);;
      9) (cd ~/games/th15 && TH_HITBOX=$hitbox ./th15e);;
      10) sdlnp21kai;;
      11) case $hitbox in off) echo focus > "$HITBOX_FILE";; focus) echo always > "$HITBOX_FILE";; always) echo off > "$HITBOX_FILE";; esac;;
      12) mpv --vo=drm --fs ~/videos/ 2>/dev/null;;
      13) exit 0;;
      14) sudo reboot;;
      15) sudo poweroff;;
    esac
  fi
done
