set fish_greeting

# QOL ALIASES
alias cd="z"
alias ll="ls -la"
alias mkcd="mkdir -p $1 && cd $1"
alias open="xdg-open"
alias zed="zeditor"
alias zz="cd .."

# DOTFILES
alias dotf="~/nixos-config/scripts/dotf/dotf.sh"

# NIXOS
alias nrs="sudo nixos-rebuild switch --flake ~/nixos-config#main-pc"
alias nixup="sudo nix flake update --flake ~/nixos-config && nrs"

# ODIN
alias odin-tracker="cp ~/nixos-config/assets/odin/mem_tracker.odin ."
alias odinb-sizesafe="odin build . -o:speed -vet -strict-style -source-code-locations:obfuscated"
alias odinb-size="odin build . -o:speed -vet -strict-style -source-code-locations:obfuscated -disable-assert -no-bounds-check"
alias odinb-fastsafe="odin build . -o:aggressive -vet -strict-style -source-code-locations:obfuscated"
alias odinb-fast="odin build . -o:aggressive -vet -strict-style -source-code-locations:obfuscated -disable-assert -no-bounds-check"

# FUNCTION ALIASES
function mkcd
    mkdir $argv[1]
    and cd $argv[1]
end
