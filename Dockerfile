FROM debian:latest AS base
# Change shell to bash
SHELL ["/bin/bash", "-ec"]
# Set image locale
ENV TZ=America/New_York
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8  
# Build neovim
ARG VERSION=master
# Arguments picked from the command line!
# TODO: password argument
ARG user
ARG uid
ARG gid
ARG password

ENV USERNAME ${user}
ENV USERPWD ${password}
# Add new user with our credentials
RUN useradd -m $USERNAME && \
  echo "$USERNAME:$USERPWD" | chpasswd && \
  usermod --shell /bin/bash $USERNAME && \
  usermod  --uid ${uid} $USERNAME && \
  groupmod --gid ${gid} $USERNAME \
  # Update debian and install needed packages
  && apt update && apt upgrade -y \
  && apt install -y \
  locales \
  bash \
  git \
  wget \
  # bash-completion \
  stow \
  ripgrep \
  fd-find \
  xsel \
  ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen \
  postgresql-client default-mysql-client \
  # sqlite3 libsqlite3-dev \ TOBE: remove
  && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen \
  # compile neovim
  && git clone https://github.com/neovim/neovim.git ~/neovim \
  && cd ~/neovim && git checkout ${VERSION} && make CMAKE_BUILD_TYPE=RelWithDebInfo install && rm -rf ~/neovim \
  # Install Lua Language Sever
  && runuser - ${user} -c 'mkdir -p $HOME/.local && cd $HOME/.local && git clone --recursive https://github.com/sumneko/lua-language-server && cd lua-language-server/3rd/luamake && ./compile/install.sh && cd ../.. && ./3rd/luamake/luamake rebuild && rm -rf 3rd test log .git*' \
  # clean up
  && apt purge ninja-build gettext libtool libtool-bin autoconf automake cmake pkg-config unzip doxygen -y \
  && apt-get clean -y \
  && apt-get autoclean -y \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/*

USER ${user}


# PATH
# export PATH=$PATH:$HOME/.local/lua-language-server/bin:$HOME/.go/bin:$HOME/go/bin:$HOME/.cargo/bin
ENV PATH=~/.local/lua-language-server/bin:~/.go/bin:~/go/bin:$PATH

# Install Go
RUN wget -q -O - https://git.io/vQhTU | bash -s -- --version 1.19

# gopls
RUN go install golang.org/x/tools/gopls@latest

# pnpm
# RUN mkdir -p ~/.local/share; ls -al ~/.local 
ENV PNPM_HOME=/home/${user}/.local/share/pnpm
ENV PATH=$PNPM_HOME:$PATH
RUN curl -fsSL https://get.pnpm.io/install.sh | bash - \
  && cd ~/.local/share/pnpm \
  && pnpm env use --global lts \
  && pnpm add -g \
  # Lsp: tsserver, (cssls, html, json), yaml, eslint, formatter:efm(prettier, stylelint, alex), bashls, tailwindcss,
  # astrojs, dockerfile
  typescript typescript-language-server \
  vscode-langservers-extracted \
  yaml-language-server \
  eslint \
  @fsouza/prettierd \
  stylelint \
  bash-language-server \
  @tailwindcss/language-server \
  @astrojs/language-server \
  dockerfile-language-server-nodejs \
  cssmodules-language-server \
  emmet-ls \
  @johnnymorganz/stylua-bin
# alex \

# bashrc file completion
COPY --chown=${user}:${user} .bashrc /home/${user}

# Clone dotfile from github repo and Creation of links
RUN git clone https://github.com/kokou2kpadenou/dotfiles.git ~/.config/.dotfiles \
  && cd ~/.config/.dotfiles/settings \
  && stow --target=/home/${user} -S stow w_o_nvimlua bash \
  # Packer.vim installation and Installation of Neovim Packages
  && git clone --depth 1 https://github.com/wbthomason/packer.nvim\
  ~/.local/share/nvim/site/pack/packer/start/packer.nvim \
  && nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync' \
  # Remove dotfiles after image build, it will be mounted later from host with volume
  && rm -rf ~/.config/.dotfiles

# TODO: Treesitter parser installation
# Try to install treesitter parser, but not working
# RUN nvim --headless +TSUpdate +qa

WORKDIR /home/${user}/Documents
