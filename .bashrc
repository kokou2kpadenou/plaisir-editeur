#
# ~/.bashrc
#

source $HOME/.profile

export PATH=$PATH:/home/neovim/.local/lua-language-server/bin:/home/neovim/go/bin:/home/neovim/.cargo/bin


# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '


set -o vi

export DOTFILES=/home/neovim/.config/.dotfiles

export EDITOR=nvim

# Aliases
if [ -e /home/neovim/.bash_aliases ]; then
    source /home/neovim/.bash_aliases
fi
