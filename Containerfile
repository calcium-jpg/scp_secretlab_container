FROM debian:bookworm

EXPOSE 7777

RUN apt-get update
RUN apt-get -y install ca-certificates gnupg
RUN gpg --homedir /tmp --no-default-keyring --keyring /usr/share/keyrings/mono-official-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN echo "deb [signed-by=/usr/share/keyrings/mono-official-archive-keyring.gpg] https://download.mono-project.com/repo/debian stable-buster main" | tee /etc/apt/sources.list.d/mono-official-stable.list
RUN dpkg --add-architecture i386
RUN apt-get update
RUN apt-get -y install mono-complete lib32gcc-s1

RUN useradd -m user
USER user

RUN mkdir /home/user/steam
ADD --chown=user "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" /home/user/
RUN tar -zxvf /home/user/steamcmd_linux.tar.gz -C /home/user/steam

RUN mkdir /home/user/scp
RUN /home/user/steam/steamcmd.sh +force_install_dir /home/user/scp +login anonymous +app_update 996560 validate +quit

RUN printf "#!/bin/sh\n/home/user/steam/steamcmd.sh +force_install_dir /home/user/scp +login anonymous +app_update 996560 validate +quit\nexec ./LocalAdmin" > /home/user/scp/run.sh

RUN chmod +x /home/user/scp/run.sh

RUN mkdir -p "/home/user/.config/SCP Secret Laboratory/config/"

# BY BUILDING THIS IMAGE YOU ACCEPT SCP: SL's EULA
RUN echo "{\"EulaAccepted\":\"$(date -u +%Y-%m-%dT%H:%M:%S.%NZ)\"}" > "/home/user/.config/SCP Secret Laboratory/config/localadmin_internal_data.json"

VOLUME ["/home/user/.config/SCP Secret Laboratory/"]

WORKDIR /home/user/scp
ENTRYPOINT ["./run.sh"]
