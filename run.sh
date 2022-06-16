# buid the image
docker build --build-arg user=$USER --build-arg uid=$(id -u) --build-arg gid=$(id -g) -t saint .

# create a xauth file with access permission
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f /tmp/.docker.xauth nmerge -

# run the docker
docker run -dit --restart unless-stopped --name saint -h saint \
  -e DISPLAY=unix$DISPLAY \
  -v /home/$USER/Documents:/home/$USER/Documents \
  -v /home/$USER/.config/.dotfiles:/home/$USER/.config/.dotfiles \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v /tmp/.docker.xauth:/tmp/.docker.xauth:rw -e XAUTHORITY=/tmp/.docker.xauth \
  saint:latest bash
