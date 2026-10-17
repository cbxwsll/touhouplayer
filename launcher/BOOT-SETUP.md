# Console boot tuning:
# /boot/firmware/cmdline.txt: append `video=HDMI-A-1:800x480@60 loglevel=1`
#   - video= locks the framebuffer to the panel's native 800x480 (sharp font)
#   - loglevel=1 keeps kernel messages from overwriting the menu
# /etc/sudoers.d/touhouplayer (mode 440):
#   cbx ALL=(ALL) NOPASSWD: /sbin/reboot, /sbin/poweroff, /usr/bin/ln, /bin/ln, /usr/bin/dmesg
# Never put a bare `sudo` in launcher.sh's startup path: it prompts for a
# password at boot and blocks the menu.