set fish_greeting

# QOL ALIASES
alias cd="z"
alias ll="ls -la"
alias open="xdg-open"
alias zed="zeditor"
alias zz="cd .."

# APPS
alias mods="rm -rf ~/sandbox/mhw-mod-manager/target && nix run ~/sandbox/mhw-mod-manager"
alias habi="~/apps/habi/target/release/habi"

# DOTFILES
alias dotf="~/nixos-config/scripts/dotf/dotf.sh"

# NIXOS
alias nrs="sudo nixos-rebuild switch --flake ~/nixos-config#main-pc"
alias nixup="nix flake update --flake ~/nixos-config && nrs"

# ODIN
alias odin-tracker="cp ~/nixos-config/assets/odin/mem_tracker.odin ."
alias odinb-safe="odin build . -o:speed -lto:thin -vet -strict-style -source-code-locations:obfuscated"
alias odinb-fast="odin build . -o:aggressive -lto:thin -vet -strict-style -source-code-locations:obfuscated -disable-assert -no-bounds-check"
