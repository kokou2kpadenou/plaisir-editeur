FROM debian:bookworm-slim

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

# ------------------------------------------------------------------------------
# Build arguments
# ------------------------------------------------------------------------------
ARG user
ARG uid
ARG gid
ARG dotfiles
ARG TARGETOS
ARG TARGETARCH

# ------------------------------------------------------------------------------
# Environment
# ------------------------------------------------------------------------------
ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    TZ=America/New_York \
    HOME=/home/${user} \
    PNPM_HOME=/home/${user}/.local/share/pnpm \
    PATH=/home/${user}/.local/share/pnpm/bin:/home/${user}/.go/bin:/home/${user}/go/bin:/usr/local/bin:${PATH}

# ------------------------------------------------------------------------------
# Base packages
# ------------------------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        curl \
        wget \
        git \
        locales \
        stow \
        ripgrep \
        fd-find \
        xsel \
        wl-clipboard \
        uuid-runtime \
        unzip \
        tar \
        postgresql-client \
        default-mysql-client \
        libstdc++6 \
        libatomic1 \
        build-essential \
        clang \
        llvm-dev \
        libclang-dev \
        pkg-config \
        libfuse2 && \
    localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------
# Install Neovim Nightly
# ------------------------------------------------------------------------------
RUN case "${TARGETARCH}" in \
      amd64) ARCH=x86_64 ;; \
      arm64) ARCH=arm64 ;; \
      *) exit 1 ;; \
    esac && \
    curl -fsSL \
      "https://github.com/neovim/neovim/releases/download/nightly/nvim-${TARGETOS}-${ARCH}.tar.gz" \
      | tar -xz -C /opt && \
    ln -s "/opt/nvim-${TARGETOS}-${ARCH}/bin/nvim" /usr/local/bin/nvim

# ------------------------------------------------------------------------------
# User
# ------------------------------------------------------------------------------
RUN if ! getent group "${gid}" >/dev/null; then \
        groupadd -g "${gid}" "${user}"; \
    fi && \
    useradd \
        --uid "${uid}" \
        --gid "$(getent group "${gid}" | cut -d: -f1)" \
        --create-home \
        --shell /bin/bash \
        "${user}" && \
    passwd -l root

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------
COPY --link --chown=${uid}:${gid} .bashrc /home/${user}/
COPY --link --chown=${uid}:${gid} scripts /home/${user}/scripts

USER ${user}
WORKDIR ${HOME}

# ------------------------------------------------------------------------------
# Install pnpm + latest Node LTS
# ------------------------------------------------------------------------------
RUN curl -fsSL https://get.pnpm.io/install.sh | \
    ENV="${HOME}/.bashrc" SHELL=/bin/bash bash && \
    pnpm runtime set node lts -g

# ------------------------------------------------------------------------------
# Install Go, LuaLS and gopls
# ------------------------------------------------------------------------------
RUN bash scripts/luals.sh && \
    bash scripts/golang_installer.sh && \
    go install golang.org/x/tools/gopls@latest

# ------------------------------------------------------------------------------
# Install dotfiles
# ------------------------------------------------------------------------------
RUN git clone --depth=1 \
        https://github.com/kokou2kpadenou/dotfiles.git \
       ${dotfiles} && \
    cd "${dotfiles}/settings" && \
    stow --target="${HOME}" -S stow w_o_nvimlua && \
    rm -rf ${dotfiles}

WORKDIR ${HOME}/Documents
