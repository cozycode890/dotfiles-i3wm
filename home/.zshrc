if [[ -o interactive && -t 1 ]]; then
  fastfetch --config arch.jsonc
fi

# =============================
# 💤 Oh My Zsh & zsh-autocomplete
# =============================
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"
ZSH_THEME=""   # dùng Starship làm prompt
ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/oh-my-zsh"

# =============================
# 📜 History (chống trùng)
# =============================
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

setopt HIST_IGNORE_DUPS       # không lưu 2 lệnh y hệt liên tiếp
setopt HIST_IGNORE_ALL_DUPS   # nếu lệnh đã có trong history -> xóa bản cũ, giữ bản mới
setopt HIST_FIND_NO_DUPS      # khi search history / dùng history menu, không show trùng
setopt HIST_SAVE_NO_DUPS      # khi ghi xuống file history, loại trùng

# Dùng vi-style keybindings trước khi load zsh-autocomplete
bindkey -v

# ---- Oh My Zsh ----
plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
)
fpath=(/usr/share/zsh/site-functions $fpath)
source "$ZSH/oh-my-zsh.sh"

# =============================
# 🌍 Môi trường & PATH
# =============================
export EDITOR=nvim
export VISUAL=nvim
export JAVA_HOME=/usr/lib/jvm/default

typeset -U path PATH
path=("$JAVA_HOME/bin" $path)

# =============================
# 🔐 SSH agent
# =============================
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-/run/user/$UID}/ssh-agent.socket"
if command -v ssh-add >/dev/null 2>&1; then
  if ! ssh-add -l >/dev/null 2>&1; then
    ssh-add ~/.ssh/id_ed25519 >/dev/null 2>&1
  fi
fi

# =============================
# 🔎 FZF
# =============================
export FZF_DEFAULT_COMMAND='fd --hidden --strip-cwd-prefix --exclude .git .'

export FZF_DEFAULT_OPTS="\
--height=40% \
--layout=reverse \
--preview 'if file --mime-type {} | grep -q image; then
  chafa {} --format=symbols --size=40x20
else
  bat --style=numbers --color=always {} || file {}
fi' \
--preview-window=right:60%"
export FZF_CTRL_T_OPTS="$FZF_DEFAULT_OPTS"
export FZF_ALT_C_OPTS="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

source ~/.config/fzf-git.sh/fzf-git.sh

# =============================
# 📁 Aliases
# =============================
alias ls="eza -a --color=always --long --no-filesize --icons=always --no-time --no-user --no-permissions --no-symlinks"
alias ll="$ls"
alias la="eza -la --color=always --icons=always"
alias tree="eza --tree --color=always --icons=always"

alias cd="z"

alias tb="adb shell pm disable-user --user 0"
alias db="adb shell pm uninstall -k --user 0"
alias ab="adb shell cmd package install-existing --user 0"

alias lg="lazygit"

alias fetch="fastfetch --config arch.jsonc"

alias rm=gomi

# =============================
# 📂 Yazi cd helper
# =============================
y() {
  local tmp cwd
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd <"$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}
alias yazi=y

# =============================
# 🎨 Giao diện & highlight
# =============================
ZSH_HIGHLIGHT_STYLES[comment]='fg=8,dim'

# =============================
# 🔗 Tích hợp
# =============================
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
eval "$(fzf --zsh)"
eval "$(gtrash completion zsh)"
eval "$(gh completion -s zsh)"

# =============================
# 🚀 Tăng tốc đọc .zshrc (zcompile)
# =============================
if command -v zcompile >/dev/null 2>&1; then
  rc="${ZDOTDIR:-$HOME}/.zshrc"
  [[ -s "${rc}.zwc" && "${rc}" -ot "${rc}.zwc" ]] || zcompile -U "$rc" 2>/dev/null
fi

# =============================
# ⌨️ Keybindings & phím tắt
# =============================

# ------------------------------
# 🪄 Lịch sử và tìm kiếm lệnh
# ------------------------------
bindkey '^K' up-history                   # Ctrl + P: lệnh trước
bindkey '^J' down-history                 # Ctrl + N: lệnh sau

# ------------------------------
# 🧩 Tiện ích thường dùng
# ------------------------------
# zoxide helper (jump thư mục)
zi() {
  local dir
  dir=$(zoxide query -l | fzf --height=40% --reverse \
    --preview 'eza -1 --color=always {}' --preview-window=right:40%) && cd "$dir"
}
if command -v zoxide >/dev/null 2>&1; then
  bindkey -s '^Z' 'zi^M'
fi

export BAT_THEME="tokyonight_moon"
