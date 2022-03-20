# buid the image
docker build -t saint .

docker run -dit --restart unless-stopped --name saint -h saint \
  -v /home/kkokou/Documents:/home/neovim/Documents \
  -v /home/kkokou/.config/.dotfiles:/home/neovim/.config/.dotfiles \
  saint:latest bash

# TODO: make clipboard works
# docker run -dit --restart unless-stopped --name saint -h saint \
#   -e DISPLAY=$DISPLAY \
#   -v /home/kkokou/Documents:/home/neovim/Documents \
#   -v /home/kkokou/.config/.dotfiles:/home/neovim/.config/.dotfiles \
#   -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
#   saint:latest bash
