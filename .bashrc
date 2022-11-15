# ~/.bashrc

export PNPM_HOME=$HOME/.local/share/pnpm

export PATH=$PATH:$HOME/.local/share/pnpm:$HOME/.local/lua-language-server/bin:$HOME/.go/bin:$HOME/go/bin:$HOME/.cargo/bin

export SETTINGS=$HOME/.config/.dotfiles/settings/w_o_nvimlua/.config/nvim

export EDITOR=nvim

export DOTFILES=$HOME/.config/.dotfiles

if [ -e $HOME/.config/nvim/package ]; then
    source $HOME/.config/nvim/package
fi

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='[\u@\h \W]\$ '
