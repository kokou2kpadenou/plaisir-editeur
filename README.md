# plaisir-editeur

A portable Neovim development environment running inside a Docker container with clipboard support, language servers, and a consistent development setup across machines.

## Goals

The project aims to:

- Easily deploy the same development environment on different machines.
- Isolate Neovim plugins, language servers, and development tools from the host system using Docker.
- Keep the host system clean while providing a reproducible development environment.

## Features

- Neovim running inside Docker
- Clipboard integration
- JavaScript / TypeScript development
- Go development
- Language servers and tooling preconfigured
- Easy access through the `dnvim` command

## Installation

### 1. Clone this repository

```bash
git clone https://github.com/kokou2kpadenou/plaisir-editeur.git \
    ~/Documents/tools/plaisir-editeur
```

### 2. Clone your dotfiles

The container relies on your dotfiles configuration.

```bash
git clone https://github.com/kokou2kpadenou/dotfiles.git \
    ~/.config/.dotfiles
```

For more information, see the dotfiles repository:

https://github.com/kokou2kpadenou/dotfiles

### 3. Source the shell configuration

Add the following to your shell configuration (for example `~/.bashrc` or `~/.zshrc`):

```bash
# Docker Neovim
if [ -e "$HOME/Documents/tools/plaisir-editeur/.bash_nvim" ]; then
    source "$HOME/Documents/tools/plaisir-editeur/.bash_nvim"
fi
```

Restart your shell or reload your configuration:

```bash
source ~/.bashrc
```

or

```bash
source ~/.zshrc
```

## First Run

Unlike previous versions, there is **no `build_image.sh` script**.

The Docker image is automatically built (if necessary) when `start_saint` is executed. Since `dnvim` calls `start_saint` internally, simply running `dnvim` for the first time will:

- build the image (if it does not already exist),
- start the container,
- launch Neovim.

The initial build may take several minutes depending on your machine and internet connection.

## Usage

### Open Neovim in the container home

```bash
dnvim
```

### Edit files

```bash
dnvim file
dnvim file1 file2
```

### Open from the current host directory

```bash
dnvim --cwd
```

Open specific files from the current directory:

```bash
dnvim --cwd init.lua
dnvim --cwd -o file1 file2
dnvim --cwd -O file1 file2
dnvim --cwd +45 init.lua
dnvim --cwd +"set number" init.lua
```

Any arguments that are not recognized by `dnvim` are forwarded directly to Neovim.

### Open a folder under `~/Documents`

```bash
dnvim --docs project
```

Example:

```bash
dnvim --docs dotfiles
dnvim --docs dotfiles init.lua
```

### Open configuration directories

```bash
dnvim --config dotfiles
dnvim --config editor
dnvim --config neovim
```

Available configuration targets:

| Command | Opens |
|---------|-------|
| `dotfiles` | Your dotfiles repository |
| `editor` | This repository (`plaisir-editeur`) |
| `neovim` | Neovim configuration directory |

### Open the container home directory

```bash
dnvim --root
```

### Display help

```bash
dnvim --help
```

## How `dnvim` Works

`dnvim` automatically:

1. Starts the Docker environment by calling `start_saint`.
2. Builds the Docker image if it does not already exist.
3. Starts the container if needed.
4. Executes Neovim inside the container.

You can therefore use `dnvim` directly without manually building or starting the environment.

## Notes

- `--cwd` only works when the current directory is inside your configured workspace.
- Any unrecognized options are passed directly to Neovim.
- Use `--` to explicitly stop `dnvim` option parsing.

Example:

```bash
dnvim --cwd -- --clean
```

## Examples

```bash
dnvim

dnvim main.go

dnvim --cwd

dnvim --cwd README.md

dnvim --docs dotfiles

dnvim --config neovim

dnvim --root

dnvim --help
```
