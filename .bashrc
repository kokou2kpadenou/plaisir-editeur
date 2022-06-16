#
# ~/.bashrc
#
alias luamake=$HOME/.local/lua-language-server/3rd/luamake/luamake

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH=$PATH:$HOME/.local/lua-language-server/bin:$HOME/go/bin:$HOME/.cargo/bin


# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

set -o vi

export DOTFILES=$HOME/.config/.dotfiles

export EDITOR=nvim

# Aliases
if [ -e $HOME/.bash_aliases ]; then
    source $HOME/.bash_aliases
fi
