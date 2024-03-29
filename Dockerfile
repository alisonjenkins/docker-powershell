FROM archlinux/archlinux:base

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
RUN echo -e "Install-Module -Name PSWSMan -AcceptLicense -Force\n" | pwsh -Command -
RUN echo -e "Install-WSMan\n" | pwsh -Command -
USER powershell
RUN echo -e "Install-Module -Name Az -AcceptLicense -Force\n" | pwsh -Command -
RUN echo -e "Install-Module -Name ExchangeOnlineManagement -Force\n" | pwsh -Command -
RUN echo -e "Import-Module ExchangeOnlineManagement; Get-Module ExchangeOnlineManagement"
CMD pwsh
