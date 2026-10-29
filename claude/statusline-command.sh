#!/usr/bin/env bash
# Status line converted from the PS1 defined in ~/.bashrc:
#   PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
#
# (~/.zshrc does not set PS1 directly; it delegates prompt rendering to the
# oh-my-zsh "robbyrussell" theme, so there was no PS1 to extract there.)

# Claude Code sends the session JSON on stdin; it is not needed for this
# PS1-derived status line, but is consumed to avoid a broken pipe.
cat > /dev/null

debian_chroot=""
if [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

chroot_prefix=""
if [ -n "$debian_chroot" ]; then
  chroot_prefix="($debian_chroot)"
fi

user=$(whoami)
host=$(hostname -s)
dir=$(pwd)

printf '%s\033[01;32m%s@%s\033[00m:\033[01;34m%s\033[00m' "$chroot_prefix" "$user" "$host" "$dir"
