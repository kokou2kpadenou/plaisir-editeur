# plaisir-editeur
My neovim development environment (neovim + language servers) for javascript, typescript and go development as a Docker image.

## Goals
The main goals are:
- To easly deploy my development environment on different machine.
- To safely separate plugins and language servers files in sandbox environment from my system file for security raisons.

## How is it built?

## Installation

TODO: talk about dotfile

First, clone this repository:

```
https://github.com/kokou2kpadenou/plaisir-editeur.git
```
After cloning:

```
cd plaisir-editeur
```

and run:
```
sh run.sh
```

The installation will take some time depending on the speed of your computer.
After installation, add the following scripts to your bash (ex: .bashrc).

```
# Access neovim in docker
if [ -e /home/kkokou/Documents/tools/plaisir-editeur/.bash_nvim ]; then
    source /home/kkokou/Documents/tools/plaisir-editeur/.bash_nvim
fi
```

And don't forget to change the path to the .bash_nvim file. I prefer to keep the file in the repository, but you can move it to your preferred folder.

## Usage

```
dnvim folder/inside/Documents
```

```
dmaint
```
