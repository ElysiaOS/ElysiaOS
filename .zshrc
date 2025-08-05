DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_COMPFIX="true"
## STARTUP
~/bin/elylogo.sh
eval "$(starship init zsh)"

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
HISTDUP=erase
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall

autoload -Uz compinit
if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)" ]; then
    compinit
else
    compinit -C
fi
# End of lines added by compinstall

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust


setopt autocd              # change directory just by typing its name
setopt correct             # auto correct mistakes
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch           # hide error message if there is no match for the pattern
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt promptsubst         # enable command substitution in prompt
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt appendhistory
setopt sharehistory

zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

## ALIASES
alias ls='ls --color=auto'
alias chmx='chmod +x'
#search filenames
alias packages="pacman -Qi | awk '/^Name/{name=\$3} /^Installed Size/{size=\$4 \" \" \$5; print name, size}' | sort -k2 -h -r"
alias paclist='pacman -Q | grep'
alias appmake='~/Scripts/appmake'
alias fgr='find | grep'
alias grep='grep --color=auto'
alias targz='tar xzvf'
alias tarn='tar xvf'
alias theme='xfce4-appearance-settings'
alias py='python3'
alias pystart='python -m venv ~/myenv
source ~/myenv/bin/activate'
alias rm='rm -i'
alias appmake='~/Scripts/appmake'
alias image='kitty +kitten icat'
alias bday='~/Elysia/bday/bday'
alias ely='kitty +kitten icat ~/bin/elyspin.gif'
alias ytdl='python -m venv ~/myenv
source ~/myenv/bin/activate
python3 ~/Music/yt-dl.py'
alias anime='fastanime --icons --default anilist'


## EXPORTS
export QT_IM_MODULE=fcitx
export GTK_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/Pictures:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export WINEPREFIX=~/HSR-prefix # REVERSE1999 PREFIX

## SNIPPETS
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found


## Plugins
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light starship/starship
zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-syntax-highlighting
zinit light zpm-zsh/ls

ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="20"
ZSH_AUTOSUGGEST_USE_ASYNC=1

### End of Zinit's installer chunk