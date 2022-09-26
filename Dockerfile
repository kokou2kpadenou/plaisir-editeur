#
FROM debian:latest AS base

# Update debian and install needed packages
RUN apt update && apt upgrade -y \
  && apt install -y \
  locales \
  bash \
  sudo \
  git \
  wget \
  bash-completion \
  stow \
  ripgrep \
  fd-find \
  xsel \
  ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen \
  postgresql-client default-mysql-client \
  sqlite3 libsqlite3-dev

# Change shell to bash
SHELL ["/bin/bash", "-ec"]

# Set image locale
ENV TZ=America/New_York
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8  

# Build neovim
ARG VERSION=master
RUN git clone https://github.com/neovim/neovim.git ~/neovim \
  && cd ~/neovim && git checkout ${VERSION} && make CMAKE_BUILD_TYPE=RelWithDebInfo install && rm -rf ~/neovim

# Arguments picked from the command line!
ARG user
ARG uid
ARG gid

# Add new user with our credentials
ENV USERNAME ${user}
RUN useradd -m $USERNAME && \
        echo "$USERNAME:$USERNAME" | chpasswd && \
        usermod --shell /bin/bash $USERNAME && \
        usermod  --uid ${uid} $USERNAME && \
        groupmod --gid ${gid} $USERNAME

USER ${user}

RUN git clone https://go.googlesource.com/go ~/go17 && \
  cd ~/go17 && \
  git checkout go1.17 && \
  cd src && \
  ./all.bash

# PATH
ENV PATH_TMP=$PATH 
ENV PATH=~/go17/bin:$PATH
 
RUN ls -a ~/go17
ENV GOROOT_BOOTSTRAP=~/go17

RUN git clone https://go.googlesource.com/go ~/go && \
  cd ~/go && \
  git checkout master && \
  cd src && \
  ./all.bash

RUN rm -rf ~/go17

# PATH
ENV PATH=~/.cargo/bin:~/go/bin:$PATH_TMP

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y


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
ENV GOPATH=/home/${user}/go
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
  dockerfile-language-server-nodejs \
  cssmodules-language-server \
  emmet-ls

# Clone dotfile from github repo and Creation of link
RUN git clone https://github.com/kokou2kpadenou/dotfiles.git ~/.config/.dotfiles \
  && cd ~/.config/.dotfiles/settings \
  && stow --target=/home/${user} -S stow w_o_nvimlua efm-langserver bash

# bashrc file completion
COPY --chown=${user}:${user} .bashrc /home/${user}

# Enables tab-completion in all npm commands
RUN source ~/.bashrc && npm completion >> ~/.bashrc

# Packer.vim installation and Installation of Neovim Packages
RUN git clone --depth 1 https://github.com/wbthomason/packer.nvim\
  ~/.local/share/nvim/site/pack/packer/start/packer.nvim \
  && nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

# TODO: Treesitter parser installation
# Try to install treesitter parser, but not working
# RUN nvim --headless +TSUpdate +qa

# Remove dotfiles after image build, it will be mounted later from host with volume
RUN rm -rf ~/.config/.dotfiles
# RUN sudo apt purge golang
#
WORKDIR /home/${user}/Documents
