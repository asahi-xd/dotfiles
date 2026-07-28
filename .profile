
# Fix needed for imv
export XCURSOR_SIZE=24
export XCURSOR_THEME=Breeze_Light

export XDG_CONFIG_HOME="$HOME/.config"
export DBX_CONTAINER_HOME_PREFIX="/mnt/Data_Drive/.distrobox"

export MANPAGER="nvim +Man!"
export PAGER="nvimpager -p"

# fps monitoring for directx games
# export DXVK_HUD=devinfo,api,version,gpuload,memory,fps,frametimes,cs

# similar thing for vulkan
# export MANGOHUD=1

# limit framerate with "DXVK_FRAME_RATE=60" for 60 fps

#emulate docker?
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock
export DOCKER_BUILDKIT=0

export LESS='-R --use-color -Dd+r$Du+b$'

export EDITOR=nvim
export SYSTEMD_EDITOR=nvim

# PATH Variables
export PATH="$HOME/.local/bin:$PATH"


export ANV_DEBUG=video-decode,video-encode

#export LIBVA_DRIVER_NAME=nvidia
export LIBVA_DRIVER_NAME=iHD
#export VDPAU_DRIVER=nvidia
export VDPAU_DRIVER=va_gl

# needed when nvidia libva driver is used
if [[ $LIBVA_DRIVER_NAME = nvidia ]]; then
    export NVD_BACKEND=direct
    export MOZ_X11_EGL=1
    export MOZ_DISABLE_RDD_SANDBOX=1
fi

# wayland specific
if [[ $(loginctl show-session "$XDG_SESSION_ID" -p Type --value) = 'wayland' ]]; then
    export QT_QPA_PLATFORM="wayland;xcb"
    export CLUTTER_BACKEND=wayland
    export ELECTRON_OZONE_PLATFORM_HINT=wayland
    export MOZ_ENABLE_WAYLAND=1
fi

# politically incorrect git
git config --global init.defaultBranch master
# fixes gtk4 apps being slow?
export GSK_RENDERER=gl
# use kde xdg portals
#export GDK_DEBUG=portals

export LIBVA_MESSAGING_LEVEL=1

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/truck/.lmstudio/bin"
# End of LM Studio CLI section

#lms server start --bind 192.168.31.250
