FROM archlinux/archlinux:base

# Work around a glibc 2.33 issue: https://serverfault.com/questions/1052963/pacman-doesnt-work-in-docker-image
RUN patched_glibc=glibc-linux4-2.33-4-x86_64.pkg.tar.zst && \
    curl -LO "https://repo.archlinuxcn.org/x86_64/$patched_glibc" && \
    bsdtar -C / -xvf "$patched_glibc"

# Initialise pacman inside the container
RUN pacman-db-upgrade
RUN pacman-key --init && pacman-key --populate archlinux
RUN pacman -Syu --noconfirm sudo fakeroot binutils

RUN useradd paru --create-home --system && \
      gpasswd -a paru wheel && \
      echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel-passwordless-sudo

# Install and setup paru
USER paru
RUN mkdir /tmp/paru && curl https://aur.archlinux.org/cgit/aur.git/snapshot/paru-bin.tar.gz -o - | tar xvz -C /tmp/paru
RUN cd /tmp/paru/paru-bin && makepkg --syncdeps --install --noconfirm

# Install powershell
RUN paru -S --noconfirm powershell-bin
USER root
RUN useradd powershell --create-home
USER powershell
CMD pwsh