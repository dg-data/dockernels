FROM jupyter/minimal-notebook:lab-3.4.5

ARG NB_USER=jovyan
ARG NB_UID=1000

# run as root
USER root

# install zeromq for ijavascript to communicate with jupyter
RUN apt-get update
RUN apt-get install -y gcc g++ make curl cmake


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

RUN apt-get -y install libsdl1.2-dev libsdl-image1.2-dev libsdl-mixer1.2-dev libsdl-ttf2.0-dev
RUN apt-get -y install libsmpeg-dev libportmidi-dev libavformat-dev libswscale-dev
RUN apt-get -y install libfreetype6-dev
ENV CHROME_DRIVER_VERSION=111.0.5563.64
RUN apt-get install -y unzip openjdk-8-jre-headless xvfb libxi6 libgconf-2-4
RUN curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list
RUN apt-get -y update
RUN apt-get -y install chromium-browser
RUN wget -N http://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip -P ~/
RUN unzip ~/chromedriver_linux64.zip -d ~/
RUN rm ~/chromedriver_linux64.zip
RUN mv -f ~/chromedriver /usr/local/bin/chromedriver
RUN chown root:root /usr/local/bin/chromedriver
RUN chmod 0755 /usr/local/bin/chromedriver

RUN pip install pygame
RUN apt-get clean

RUN npm install -g --unsafe-perm ijavascript

# install ijsinstall no longer needed
RUN ijsinstall

COPY package.json "/home/${NB_USER}/work/package.json"
COPY package-lock.json "/home/${NB_USER}/work/package-lock.json"
COPY environment.yml "${HOME}/environment.yml"
COPY files/*.* /
# Allow their execution
RUN chmod -R +x /*.sh
RUN /copy_content.sh
RUN chown -R "${NB_USER}" "/home/${NB_USER}/work"
RUN chown -R "${NB_USER}" "/home/${NB_USER}/.local"

# run as jovyan
USER "${NB_USER}"

WORKDIR "/home/${NB_USER}/work"
# RUN conda install anaconda-client -n base
RUN test -f ${HOME}/environment.yml && mamba env update -p /opt/conda -f ${HOME}/environment.yml  && \
    test -f ${HOME}/postBuild && chmod +x ${HOME}/postBuild && ${HOME}/postBuild || exit 0
RUN pip install --no-cache --upgrade pip && \
    pip install --no-cache nbgitpuller && \
    pip install --no-cache jupyter-offlinenotebook
RUN jupyter serverextension enable --py nbgitpuller --sys-prefix
RUN jupyter labextension install @j123npm/qgrid2@1.1.4

RUN npm install

# https://discourse.jupyter.org/t/custom-docker-image-spawn-fails-on-mybinder-org/16448/5
ENV PATH="${HOME}/.local/bin:${PATH}"
