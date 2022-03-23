# buid the image
docker build -t diablo .

docker run -dit --restart unless-stopped --name diablo -h diablo \
  -v /home/kkokou/Documents:/home/neovim/Documents \
  -v /home/kkokou/.config/.dotfiles:/home/neovim/.config/.dotfiles \
  diablo:latest bash
