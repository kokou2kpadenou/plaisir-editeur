# Build neovim separately in the first stage
FROM archlinux:latest AS base

# Update archlinx and install needed packages
RUN pacman -Syu --noconfirm \
  && pacman -S --noconfirm \
  bash \
  curl \
  sudo \
  git \
  base-devel \
  cmake \
  unzip \
  ninja \
  tree-sitter \
  wget \
  bash-completion \
  stow \
  ripgrep \
  fd \
  rust cargo \
  go


# Set timezone and langue
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
  && sed -i '/^#en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen \
  && echo "LANG=en_US.UTF-8" > /etc/locale.conf && locale-gen

# Build neovim
ARG VERSION=master
RUN git clone https://github.com/neovim/neovim.git ~/neovim \
  && cd ~/neovim && git checkout ${VERSION} && make CMAKE_BUILD_TYPE=RelWithDebInfo install

# Create user neovim
ARG UNAME=neovim
RUN useradd -m ${UNAME} && echo "$UNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/${UNAME}

# Change to neovim
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
RUN cargo install stylua

# Lsp: efm-server and gopls
RUN go install github.com/mattn/efm-langserver@latest \
  && go install golang.org/x/tools/gopls@latest

# NVM (nodejs) and some lsp base on nodejs
ARG VERSION_OF_NVM=v0.39.1
RUN touch ~/.bashrc && chmod +x ~/.bashrc \
  && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${VERSION_OF_NVM}/install.sh | bash
RUN . ~/.nvm/nvm.sh \
  && source ~/.bashrc \
  && nvm install node \
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

# Clone dotfile from github repo and Creation of link
RUN git clone https://github.com/kokou2kpadenou/dotfiles.git ~/.config/.dotfiles \
  && cd ~/.config/.dotfiles/settings \
  && stow --target=/home/neovim -S stow w_o_nvimlua efm-langserver bash

# bashrc file completion
COPY --chown=neovim:neovim .bashrc /home/neovim

# Packer.vim installation and Installation of Neovim Packages
RUN git clone --depth 1 https://github.com/wbthomason/packer.nvim\
  ~/.local/share/nvim/site/pack/packer/start/packer.nvim \
  && nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

# TODO: Treesitter parser installation
# Try to install treesitter parser, but not working
# RUN nvim --headless +TSUpdate +qa

# Remove dotfiles after image build, it will be mounted from host with volume
RUN rm -rf ~/.config/.dotfiles
#
WORKDIR /home/neovim/Documents
