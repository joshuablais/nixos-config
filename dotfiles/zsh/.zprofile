# Guix
if [ -f "$HOME/.guix-profile/etc/profile" ]; then
  source "$HOME/.guix-profile/etc/profile"
fi

if [ -f "$HOME/.config/guix/current/etc/profile" ]; then
  source "$HOME/.config/guix/current/etc/profile"
fi
