# ~/.bashrc

export PNPM_HOME=$HOME/.local/share/pnpm

export PATH=$PATH:$HOME/.local/share/pnpm:$HOME/.local/lua-language-server/bin:$HOME/.go/bin:$HOME/go/bin:$HOME/.cargo/bin

export SETTINGS=$HOME/.config/.dotfiles/settings/w_o_nvimlua/.config/nvim

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
