FROM debian:stable-slim AS base

# Change shell to bash
SHELL ["/bin/bash", "-ec"]

# Set image locale
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
ENV TZ=America/New_York
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8  

# Build neovim
ARG VERSION=master

# Arguments picked from the command line!
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
  && apt update \
  && apt install -y \
  bash \
  git \
  wget \
  stow \
  ripgrep \
  fd-find \
  xsel \
  ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen \
  postgresql-client default-mysql-client \
  # sqlite3 libsqlite3-dev \ TOBE: remove
  # compile neovim
  && git clone https://github.com/neovim/neovim.git ~/neovim \
  && cd ~/neovim && git checkout ${VERSION} && make CMAKE_BUILD_TYPE=RelWithDebInfo install && rm -rf ~/neovim \
  # Install Lua Language Sever
  && runuser - ${user} -c 'mkdir -p $HOME/.local && cd $HOME/.local && git clone --recursive https://github.com/sumneko/lua-language-server && cd lua-language-server/3rd/luamake && ./compile/install.sh && cd ../.. && ./3rd/luamake/luamake rebuild && rm -rf 3rd test log .git*' \
  # pnpm
  && runuser - ${user} -c 'export PNPM_HOME=$HOME/.local/share/pnpm && export PATH=$PNPM_HOME:$PATH && curl -fsSL https://get.pnpm.io/install.sh | bash - && cd $HOME/.local/share/pnpm && pnpm env use --global lts' \
  # clean up
  && apt purge ninja-build gettext libtool libtool-bin autoconf automake cmake pkg-config unzip doxygen -y \
  && apt-get clean -y \
  && apt-get autoclean -y \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/* \
  && echo "root:$USERPWD" | chpasswd

USER ${user}

# PATH
ENV PATH=~/.go/bin:~/go/bin:$PATH

# Install Go and gopls
RUN wget -q -O - https://git.io/vQhTU | bash -s -- --version 1.19 \
  && go install golang.org/x/tools/gopls@latest

# bashrc
COPY --chown=${user}:${user} .bashrc /home/${user}
# bash_1ststart
COPY --chown=${user}:${user} .bash_1ststart /home/${user}

# Clone dotfile from github repo and Creation of links
RUN git clone https://github.com/kokou2kpadenou/dotfiles.git ~/.config/.dotfiles \
  && cd ~/.config/.dotfiles/settings \
  && stow --target=/home/${user} -S stow w_o_nvimlua \
  # Install neovim plugin
  && nvim --headless -c 'autocmd User PackerComplete quitall' \
  # Remove dotfiles after image build, it will be mounted later from host with volume
  && rm -rf ~/.config/.dotfiles

WORKDIR /home/${user}/Documents
