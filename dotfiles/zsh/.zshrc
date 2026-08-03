# SYSTEM
PATH=/home/rcsaquino/.local/bin:$PATH

# ZSH THEME
export ZSH="/usr/share/oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# ZSH PLUGINS
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# ZOXIDE
eval "$(zoxide init zsh)"

# FZF
source <(fzf --zsh)

# NVM
source /usr/share/nvm/init-nvm.sh

# SEE INSTALLED/DELETED PACKAGES
alias aqqe="comm -13 <(sort ~/factory_pkgs/factory_Qqet.txt) <(paru -Qqet | sort)"
alias dqqe="comm -23 <(sort ~/factory_pkgs/factory_Qqet.txt) <(paru -Qqet | sort)"
alias aqqet="comm -13 <(sort ~/factory_pkgs/factory_Qqe.txt) <(paru -Qqe | sort)"
alias dqqet="comm -23 <(sort ~/factory_pkgs/factory_Qqe.txt) <(paru -Qqe | sort)"

# QOL ALIASES
alias la="ls -A"
alias open="xdg-open"
alias zed="zeditor"
alias zz="cd .."

# ZIG
alias zig-utils="cp ~/linux-config/assets/zig/utils.zig ."
alias zigi="cp -a ~/linux-config/assets/zig/zig-init-template/. . && sed -i "s/change_me/$(basename "$PWD")/g" build.zig && zig init -m 2>/dev/null"
alias zigr="zig build run --"
alias zigb="zig build -Doptimize=ReleaseFast"

# ODIN
alias odin-tracker="cp ~/linux-config/assets/odin/mem_tracker.odin ."
alias odinb-sizesafe="odin build . -o:speed -vet -strict-style -source-code-locations:obfuscated"
alias odinb-size="odin build . -o:speed -vet -strict-style -source-code-locations:obfuscated -disable-assert -no-bounds-check"
alias odinb-fastsafe="odin build . -o:aggressive -vet -strict-style -source-code-locations:obfuscated"
alias odinb-fast="odin build . -o:aggressive -vet -strict-style -source-code-locations:obfuscated -disable-assert -no-bounds-check"

# FUNCTIONS
pdfpp() {
  rm -rf ~/Downloads/tmp_pdfpp
  mkdir ~/Downloads/tmp_pdfpp
  pdftoppm -jpeg ~/Downloads/tmp.pdf ~/Downloads/tmp_pdfpp/page
  xdg-open ~/Downloads/tmp_pdfpp
  rm -rf ~/Downloads/tmp.pdf
}
