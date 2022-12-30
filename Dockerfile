FROM jupyter/minimal-notebook:lab-3.5.0

ARG NB_USER=jovyan
ARG NB_UID=1000

# run as root
USER root

# install zeromq for ijavascript to communicate with jupyter
RUN apt-get update
RUN apt-get install -y gcc g++ make curl cmake

#RUN apt-get install -yq --no-install-recommends libzmq3-dev
RUN apt-get install -y libzmq3-dev
RUN apt-get -y install --no-install-recommends \
   dbus-x11 \
   ffmpeg \
   firefox \
   xfce4 \
   xfce4-panel \
   xfce4-session \
   xfce4-settings \
   xorg \
   xubuntu-icon-theme \
   ffmpeg pkg-config libatlas-base-dev

RUN apt-get -y install libsdl-dev libsdl-image1.2-dev libsdl-mixer1.2-dev libsdl-ttf2.0-dev
RUN apt-get -y install libsmpeg-dev libportmidi-dev libavformat-dev libswscale-dev
RUN apt-get -y install libfreetype6-dev
RUN apt-get -y install libportmidi-dev
RUN pip install pygame
RUN apt-get clean

RUN npm install -g --unsafe-perm ijavascript

# install ijsinstall no longer needed
RUN ijsinstall

COPY package.json "/home/${NB_USER}/work/package.json"
COPY package-lock.json "/home/${NB_USER}/work/package-lock.json"

RUN chown -R "${NB_USER}" "/home/${NB_USER}/work"
RUN chown -R "${NB_USER}" "/home/${NB_USER}/.local"

# run as jovyan
USER "${NB_USER}"

WORKDIR "/home/${NB_USER}/work"
RUN pip install --no-cache --upgrade pip && \
    pip install --no-cache nbgitpuller
RUN jupyter serverextension enable --py nbgitpuller --sys-prefix

RUN npm install

# https://discourse.jupyter.org/t/custom-docker-image-spawn-fails-on-mybinder-org/16448/5
ENV PATH="${HOME}/.local/bin:${PATH}"
