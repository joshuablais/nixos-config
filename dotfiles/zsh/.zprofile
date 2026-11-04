# ~/.zprofile

# User packages first; the pulled guix last, so it wins in PATH.
# GUIX_PROFILE must be set, or etc/profile bakes in a frozen /gnu/store path.
GUIX_PROFILE="$HOME/.guix-profile"
[ -f "$GUIX_PROFILE/etc/profile" ] && . "$GUIX_PROFILE/etc/profile"

GUIX_PROFILE="$HOME/.config/guix/current"
[ -f "$GUIX_PROFILE/etc/profile" ] && . "$GUIX_PROFILE/etc/profile"

unset GUIX_PROFILE

# Only if glibc-locales is actually installed in the user profile.
[ -d "$HOME/.guix-profile/lib/locale" ] && export GUIX_LOCPATH="$HOME/.guix-profile/lib/locale"
