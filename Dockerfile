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
    libsdl2-mixer-dev  \
    cmake \
    ffmpeg \
    gputils \
    libsdl2-dev  \
    libsdl2-image-dev \
    libsdl2-ttf-dev  \
    python3-pygame
RUN apt-get clean

RUN pip install --no-cache --upgrade pip && \
    pip install --no-cache nbgitpuller
RUN jupyter serverextension enable --py nbgitpuller --sys-prefix

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

RUN npm install

# https://discourse.jupyter.org/t/custom-docker-image-spawn-fails-on-mybinder-org/16448/5
ENV PATH="${HOME}/.local/bin:${PATH}"
