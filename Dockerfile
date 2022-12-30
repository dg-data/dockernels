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
    alsa-utils \
    ca-certificates \
    libasound2 libasound2-plugins \
    libportmidi0 libportmidi-dev \
    gcc automake autoconf libtool git make direnv \
    libespeak-ng1 libespeak-ng-dev espeak-ng-data espeak-ng \
    sox swig ffmpeg curl pkg-config libatlas-base-dev

RUN apt-get install -y python3-pyaudio libsdl-ttf2.0-0 python3-pygame
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
