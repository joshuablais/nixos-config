# PATH
export PATH=$PATH:~/.local/bin
export PATH=$PATH:~/.config/scripts
export PATH=$PATH:~/.config/scripts/Automations
export PATH=$PATH:~/.config/scripts/Development
export PATH=$PATH:~/.config/scripts/Misc
export PATH=$PATH:~/.config/scripts/Media
export PATH=$PATH:~/.config/scripts/Accounting
export PATH=$PATH:~/.config/scripts/Dotfiles
export PATH="$HOME/.tmux/plugins/tmuxifier/bin:$PATH"
export PATH="$PATH:$HOME/go/bin"
export PNPM_HOME="/home/joshua/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# ENVIRONMENT
export EDITOR="emacs"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=4'

# SHELL OPTIONS
setopt CORRECT
setopt AUTO_CD
SAVEHIST=10000
HISTFILE=~/.zsh_history
bindkey -e

# FZF FUNCTIONS
fcd() {
  cd "$(find -type d | fzf --preview 'tree -C {} | head -200' --preview-window 'up:60%')"
}

fe() {
  emacs -nw "$(find -type f | fzf --preview 'cat {}' --preview-window 'up:60%')"
}

frg() {
  RG_PREFIX="rga --files-with-matches"
  local file
  file="$(
    FZF_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
      fzf --sort --preview="[[ ! -z {} ]] && rga --pretty --context 5 {q} {}" \
          --phony -q "$1" \
          --bind "change:reload:$RG_PREFIX {q}" \
          --preview-window="70%:wrap"
  )" && echo "opening $file" && xdg-open "$file"
}

pe() {
  local file
  file=$(find ~/.password-store -type f -name '*.gpg' \
    | sed "s|^$HOME/.password-store/||;s|\.gpg$||" \
    | fzf)
  [[ -n "$file" ]] && pass edit "$file"
}

frm() {
  local selected
  selected=$(find . -type f -o -type d 2>/dev/null | fzf -m)
  if [[ -n "$selected" ]]; then
    echo "Deleting:"
    echo "$selected"
    echo "$selected" | xargs -d '\n' rm -rf
  else
    echo "No selection."
  fi
}

ssh_fzf() {
  local host
  host=$(grep "Host " ~/.ssh/config | cut -d " " -f 2 | fzf)
  [[ -n "$host" ]] && ssh "$host" || echo "No host selected"
}

# cd + list (function wins over any alias)
function cd {
  builtin cd "$@" && eza -l --icons
}

# yazi with cwd tracking
function r() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
    cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# ALIASES — Programs
alias cat="bat"
alias cl="clear"
alias ls="eza -l --icons"
alias la="eza -TL 2 --icons"
alias py="python"
alias ytd='yt-dlp'
alias src="source ~/.zshrc"
alias v="nvim"
alias f="thunar . &"
alias ff="fastfetch"
alias zr="zig run"

# ALIASES — Navigation
alias photos="cd ~/Photos"
alias revere="cd ~/Revere"
alias revereb="cd ~/Revere/Revere\ LATEST/Brokerage"
alias commer="cd ~/Revere/Revere\ LATEST/Brokerage/Alberta/Edmonton/Deals/2025/Commercial"
alias sellers="cd ~/Revere/Revere\ LATEST/Brokerage/Alberta/Edmonton/Deals/2025/Sellers"
alias buyers="cd ~/Revere/Revere\ LATEST/Brokerage/Alberta/Edmonton/Deals/2025/Buyers"
alias revsys="cd ~/Revere/Revere\ LATEST/Systems"
alias nas="cd /mnt/nomad/TrueNAS"
alias media="cd /mnt/nomad/TrueNAS/media"
alias music="cd ~/Music"
alias movies="cd /mnt/nomad/TrueNAS/media/Movies"
alias library="cd /mnt/nomad/TrueNAS/Library"
alias scripts="cd ~/.config/scripts"
alias mpray="nvim ~/Vaults/Personal/Prayers/Morning\ Prayers.md"
alias epray="nvim ~/Vaults/Personal/Prayers/Evening\ Prayers.md"

# ALIASES — Emacs
alias emacs="GDK_BACKEND=x11 emacs"

# ============================================================
# ALIASES — NixOS
# ============================================================
alias nrs="nh os switch . --hostname"
alias nrs-empirica="nixos-rebuild switch --flake .#empirica --target-host joshua@192.168.0.28 --sudo"
alias ns="nh search"
alias nrb="sudo nixos-rebuild build --flake"
alias nrsf='sudo nixos-rebuild switch --no-reexec'
alias ngc="sudo nix-collect-garbage --delete-older-than 14d"
alias ngenlist="sudo nix-env --profile /nix/var/nix/profiles/system --list-generations"
alias nopt="sudo nix-store --optimise"
alias nb="nix build"
alias nr="nix run"
alias dalw="direnv allow"
alias drel="direnv reload"
alias backup="sudo systemctl start restic-backups-daily.service"
alias nfc="nix flake check --impure"
alias nfu="nix flake update"
alias nfuq="nix flake update && nix flake check --impure"
alias colmena="colmena apply"

# ============================================================
# ALIASES — Networking
# ============================================================
alias nmconnect="nmcli device wifi connect"
alias nmdown="nmcli c delete"
alias nmlist="nmcli device wifi list"
alias nmdelete="nmcli device delete"
alias startvpn="sudo systemctl start wg-quick@wg0"
alias stopvpn="sudo systemctl stop wg-quick@wg0"
alias logos="mosh joshua@logos -- tmux new-session -A -s main"

# ALIASES — Tmux
alias kat="tmux kill-server"
alias t="TERM=screen-256color-bce tmux"
alias tat="tmux attach -t"
alias tsf="tmux source-file ~/.tmux.conf"
alias tk="tmux kill-session -a"

# ALIASES — Development
alias create="nix run github:joshuablais/go-creation --"
alias create-flake="~/.config/scripts/Development/create-flake.sh"
alias secrets="nix run github:joshuablais/go-secrets --"
alias newrepo="nix run github:joshuablais/go-repo"
alias rawurl="py ~/.config/scripts/githubcurlurl.py"
alias grao="git remote add origin"
alias keygen="nix run github:joshuablais/go-api-key"
alias gdoc="stdsym | fzf --preview 'go doc {}' | xargs go doc"
alias adwflw="~/Development/workflows/scripts/add-workflow.sh"
alias syncmedia="~/.config/scripts/Development/rclone/rclone.sh"
alias deployapp="~/.config/scripts/Development/deploy"
alias blogdeploy="deployapp blogrevamp joshblais.com auto"
alias deployato="deployapp acetheosce acetheosce.com auto"
alias lh="~/.config/scripts/Development/lighthouse.sh"

# templ/go-task
alias tf="templ fmt ."
alias tg="templ generate"
alias tr="go-task run"
alias tm="go-task migrate"
alias tb="go-task templ"
alias ttw="go-task tailwindcss"

# ALIASES — Containers (podman)
alias 'docker compose'="podman compose"
alias dcd="podman compose down"
alias dcu="podman compose up -d"
alias dcb='podman build -t forge.labrynth.org/josh/$(basename $PWD):latest .'
alias dc="podman compose"
alias dps="podman ps -a"
alias dl="podman logs"

# ALIASES — Scripts / Media
alias w2pdf="wkhtmltopdf"
alias devwork="~/.config/scripts/Development/devwork.sh"
alias resolvefmt="~/.config/scripts/Media/resolve.sh"
alias f2p="~/.config/scripts/file_2_phone.sh"
alias eopn="~/.config/scripts/manage_encrypted_drives eopn"
alias ecls="~/.config/scripts/manage_encrypted_drives ecls"
alias rs="~/.config/scripts/gammastep.sh"
alias rsx="killall gammastep"
alias gst="go run ~/.config/scripts/Accounting/GST.go"
alias remit="go run ~/.config/scripts/Accounting/GSTRemit.go"
alias pg="pass generate"
alias sd="spotdl --yt-dlp-args '--cookies-from-browser firefox'"
alias nm="neomutt"
alias syncvault="rsync -avz --delete /mnt/TrueNAS/ /mnt/Vault/TrueNAS"
alias syncnas="rsync -avz --delete /mnt/nomad/TrueNAS/ /mnt/External4TB/TrueNAS"
alias syncrev="rsync -avz --delete '/home/joshua/Revere/Revere LATEST/' '/mnt/nomad/TrueNAS/Revere/Revere LATEST/'"
alias mntnas="sshfs joshua@172.18.250.13:/mnt/Vault /mnt/Logos"
alias umountnas="fusermount -u /mnt/Logos"
alias mntexternal="sudo mount /dev/sdb1 /mnt/External4TB"
alias mntvault="sudo mount /dev/sda /mnt/Logos"
alias record="arecord -f cd output.wav"
alias osrs="flatpak run com.adamcake.Bolt"
alias strip="mogrify -strip"
alias kmon="kmonad ~/.config/kmonad/config.kbd &"
alias kbon="sudo echo 0 | sudo tee /sys/class/input/event0/device/inhibited"
alias kboff="sudo echo 1 | sudo tee /sys/class/input/event0/device/inhibited"
alias ytmp3="~/.config/scripts/Media/ytmp3.sh"
alias aa="python ~/.config/scripts/Media/albumartwork.py"
alias mpdupdate="~/.config/scripts/Media/mpdupdate.sh"
alias dailysites="~/.config/scripts/Misc/dailysites"
alias search-email='~/.config/scripts/email_search'
alias anime="~/.config/scripts/ani-cli/ani-cli"
alias brodirs="mkdir 'Brokerage Documents' 'Offer' 'Conveyancing' 'Payout' 'Posts'"
alias work="arttime --nolearn -a eye -t 'For I consider that the sufferings of this present time are not worth comparing with the glory that is going to be revealed to us - Romans 8:18' -g 4h"

# ALIASES — Payouts / GIMP
alias letterhead="cd /mnt/nomad/TrueNAS/Revere/Revere\ LATEST/Logos\ and\ Assets/Letterhead/2022/"
alias eftinfo="gimp ~/Revere/Revere\ LATEST/Logos\ and\ Assets/Letterhead/2022/Paid\ by\ EFT.xcf"
alias invoice="gimp ~/Revere/Logos\ and\ Assets/Letterhead/2022/Invoice\ Template.xcf"
alias cinst="gimp ~/Revere/Systems/Conveyancing/Templates/Conveyancing\ Instructions\ Template.xcf"
alias cominv="gimp ~/Revere/Logos\ and\ Assets/Letterhead/2022/Commission\ Invoice\ Template.xcf"
alias cashback="gimp ~/Revere/Logos\ and\ Assets/Letterhead/2022/Cashback\ Template.xcf"
alias payout="gimp ~/Revere/Systems/Templates/Invoicing\ Templates/Paystub\ Template.xcf"
alias payoutCody="gimp ~/Revere/Brokerage/Alberta/Edmonton/Agents/Paystubs/Paystub\ -\ Cody\ Serediak.xcf"
alias payoutSeth="gimp ~/Revere/Brokerage/Alberta/Edmonton/Agents/Paystubs/Paystub\ -\ Seth\ Macdonald.xcf"
alias reverecalc="cd ~/Revere/Systems/Programs/Calculators && python ConveyancingOutput.py"
alias buyercalc="cd ~/Revere/Systems/Programs/Calculators && python BuyerCommissionCalc.py"

# INIT
eval "$(starship init zsh)"
eval "$(tmuxifier init -)"
eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"
eval "$(atuin init zsh)"

export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh"
