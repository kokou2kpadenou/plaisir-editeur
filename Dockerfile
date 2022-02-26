# Build neovim separately in the first stage
FROM alpine:latest AS base

# Maintainer
MAINTAINER KOKOU KPADENOU

RUN apk --no-cache add \
    autoconf \
    automake \
    build-base \
    cmake \
    ninja \
    coreutils \
    curl \
    gettext-tiny-dev \
    git \
    libtool \
    pkgconf \
    unzip

# Build neovim (and use it as an example codebase
RUN git clone https://github.com/neovim/neovim.git

ARG VERSION=master
RUN cd neovim && git checkout ${VERSION} && make CMAKE_BUILD_TYPE=RelWithDebInfo install

# To support kickstart.nvim
RUN apk --no-cache add \
    fd  \
    ctags \
    ripgrep \
    git

# Copy the kickstart.nvim init.lua
# COPY ./init.lua /root/.config/nvim/init.lua

# Clone my dofile repo
RUN git clone https://github.com/kokou2kpadenou/dotfiles.git /root/.config/.dotfiles

# Install lua-language-server
RUN apk --no-cache add \
    git \
    build-base \
    ninja \
    bash

RUN mkdir -p /root/.local && \
    cd /root/.local &&  \
    git clone --recursive https://github.com/sumneko/lua-language-server && \
    cd lua-language-server/3rd/luamake && \
    ./compile/install.sh && \
    cd ../.. && \
    ./3rd/luamake/luamake rebuild

# stylua
RUN apk --no-cache add rust cargo

RUN cargo install stylua


## Lsp: efm-server
RUN apk --no-cache add go

RUN go install github.com/mattn/efm-langserver@latest

# Lsp: gopls
RUN apk --no-cache add go

RUN go install golang.org/x/tools/gopls@latest

# Lsp: tsserver, (cssls, html, json), yaml, eslint, formatter:efm(prettier, stylelint, alex), bashls, tailwindcss
RUN apk --no-cache add nodejs npm

RUN npm i -g \
    typescript typescript-language-server \
    vscode-langservers-extracted \
    yaml-language-server \
    eslint \
    @fsouza/prettierd \
    stylelint \
    alex \
    bash-language-server \
    @tailwindcss/language-server \
    @astrojs/language-server

ENV ENV="/root/.ashrc"

RUN echo "export PATH=$PATH:/root/.local/lua-language-server/bin:/root/go/bin:/root/.cargo/bin" >> "$ENV"
RUN echo "alias ls='ls --color=auto'" >> "$ENV"
RUN echo "PS1='[\u@\h \W]\$ '" >> "$ENV"
RUN echo "set -o vi" >> "$ENV"
RUN echo "export DOTFILES=/root/.config/.dotfiles" >> "$ENV"
RUN echo "export EDITOR=nvim" >> "$ENV"

# Add clangd extras
RUN apk --no-cache add \
    clang-extra-tools

RUN apk --no-cache add stow

RUN cd /root/.config/.dotfiles/settings && stow --target=/root -S stow w_o_nvimlua

RUN cd -

RUN git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim

RUN nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

WORKDIR /outside
