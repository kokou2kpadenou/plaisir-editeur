# Build neovim separately in the first stage
FROM alpine:latest AS base

RUN apk --no-cache add -U \
  tzdata \
  sudo \
  git \
  build-base \
  cmake \
  automake \
  autoconf \
  ninja \
  libtool \
  pkgconf \
  coreutils \
  unzip \
  gettext-tiny-dev \
  wget \
  xsel \
  bash-completion \
  stow \
  fzf \
  ripgrep \
  fd \
  go \
  curl bash ca-certificates openssl ncurses coreutils \
  python3 make gcc g++ libgcc linux-headers grep util-linux binutils findutils


# Set timezone and language
ENV TZ=America/New_York
ENV LANG en_US.UTF-8
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# language
# RUN sed -i '/^#en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
# RUN echo "LANG=en_US.UTF-8" > /etc/locale.conf && locale-gen

# Build neovim
ARG VERSION=master
RUN git clone https://github.com/neovim/neovim.git ~/neovim \
  && cd ~/neovim && git checkout ${VERSION} && make CMAKE_BUILD_TYPE=RelWithDebInfo install

# Create user neovim
ARG UNAME=neovim
RUN addgroup -g 1000 -S ${UNAME} \
  && adduser -S ${UNAME} -u 1000 -G ${UNAME} \
  && echo "${UNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
# Switch to neovim
USER ${UNAME}

# Install lua-language-server
RUN mkdir -p ~/.local \
  && cd ~/.local \
  && git clone --recursive https://github.com/sumneko/lua-language-server \
  && cd lua-language-server/3rd/luamake \
  && ./compile/install.sh \
  && cd ../.. \
  && ./3rd/luamake/luamake rebuild \
  && cd ~

# stylua
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
  && source $HOME/.cargo/env \
  && cargo install stylua --features lua52

# Lsp: efm-server and gopls
RUN go install github.com/mattn/efm-langserver@latest \
  && go install golang.org/x/tools/gopls@latest

# NVM (nodejs) and some nodejs based lsp
ARG VERSION_OF_NVM=v0.39.1
RUN touch ~/.bashrc && chmod +x ~/.bashrc \
  && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${VERSION_OF_NVM}/install.sh | bash \
  && NVM_DIR="$HOME/.nvm" \
  && . ~/.nvm/nvm.sh \
  && source ~/.bashrc \
  && nvm install -s node \
  && nvm use node \
  && nvm alias default node \
  && npm i -g npm@latest \
  # Lsp: tsserver, (cssls, html, json), yaml, eslint, formatter:efm(prettier, stylelint, alex), bashls, tailwindcss,
  # astrojs, dockerfile
  && npm i -g \
  typescript typescript-language-server \
  vscode-langservers-extracted \
  yaml-language-server \
  eslint \
  @fsouza/prettierd \
  stylelint \
  alex \
  bash-language-server \
  @tailwindcss/language-server \
  @astrojs/language-server \
  dockerfile-language-server-nodejs

# Clone dotfile from github repo - Creation of link
RUN git clone https://github.com/kokou2kpadenou/dotfiles.git ~/.config/.dotfiles \
  && cd ~/.config/.dotfiles/settings \
  && stow --target=/home/neovim -S stow w_o_nvimlua efm-langserver bash

# bashrc file
COPY .bashrc /home/neovim

# Packer.vim installation - Installation of Neovim Packages
RUN git clone --depth 1 https://github.com/wbthomason/packer.nvim \
  ~/.local/share/nvim/site/pack/packer/start/packer.nvim \
  && nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

# TODO: Treesitter parser installation
# Try to install treesitter parser, but not working
# RUN nvim --headless +TSUpdate +qa

# Remove dotfiles after image build, it will be mounted from host with volume
RUN rm -rf ~/.config/.dotfiles
#
WORKDIR /home/neovim/Documents
