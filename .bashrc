#
# ~/.bashrc
#
alias luamake=$HOME/.local/lua-language-server/3rd/luamake/luamake

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH=$PATH:$HOME/.local/lua-language-server/bin:$HOME/.go/bin:$HOME/go/bin:$HOME/.cargo/bin

export NVIM=$HOME/.config/.dotfiles/settings/w_o_nvimlua/.config/nvim

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='[\u@\h \W]\$ '

set -o vi

export DOTFILES=$HOME/.config/.dotfiles

export EDITOR=nvim

# Aliases
if [ -e $HOME/.bash_aliases ]; then
    source $HOME/.bash_aliases
fi

# Bash completion
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi
