# plaisir-editeur

Neovim development environment (neovim + language servers) for javascript, typescript and go development as a Docker image with clipboard support.

## Goals

The main goals are:

- To easly deploy my development environment on different machine.
- To safely separate plugins and language servers files in sandbox environment from my system file for security raisons.

## How is it built?

## Installation

TODO: talk about dotfile

First, clone these two repositories:

To build the docker image

```
git clone https://github.com/kokou2kpadenou/plaisir-editeur.git ~/Documents/tools/plaisir-editeur
```

Configuration files needed for the docker image to work. For more details see [dotfiles](https://github.com/kokou2kpadenou/dotfiles)

```
git clone https://github.com/kokou2kpadenou/dotfiles.git ~/.config/.dotfiles
```

After cloning:

```
cd ~/Documents/tools/plaisir-editeur
```

and run:

```
sh build_image.sh
```

The installation will take some time depending on the speed of your computer.
After installation, add the following scripts to your bash (ex: .bashrc).

```
# Access neovim in docker
if [ -e $HOME/Documents/tools/plaisir-editeur/.bash_nvim ]; then
    source $HOME/Documents/tools/plaisir-editeur/.bash_nvim
fi
```


## Usage

```
dnvim project/folder
```

```
dmaint
```
