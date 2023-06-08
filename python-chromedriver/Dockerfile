# docker build -t registry.cn-beijing.aliyuncs.com/windli/python-chromedriver-flow:1.0 -f Dockerfile ..
#phase1, download noVNC and frp
FROM python:3.10-alpine as downloader
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.15/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.15/community" >> /etc/apk/repositories && \
    apk update && \
    apk add curl unzip

########################################
# noVNC exposes VNC through a web page #
########################################
ENV NOVNC_VERSION="1.4.0" \
    WEBSOCKIFY_VERSION="0.11.0"
RUN env HTTPS_PROXY=http://home.alot.pw:18888 curl -skL -o noVNC.zip \
       "https://github.com/novnc/noVNC/archive/refs/tags/v${NOVNC_VERSION}.zip" \
  && unzip -x noVNC.zip \
  && mkdir -p /opt/bin/ && mv noVNC-${NOVNC_VERSION} /opt/bin/noVNC \
  && cp /opt/bin/noVNC/vnc.html /opt/bin/noVNC/index.html \
  && rm noVNC.zip \
  && env HTTPS_PROXY=http://home.alot.pw:18888 curl -skL -o websockify.zip \
      "https://github.com/novnc/websockify/archive/refs/tags/v${WEBSOCKIFY_VERSION}.zip" \
  && unzip -x websockify.zip \
  && rm websockify.zip \
  && rm -rf websockify-${WEBSOCKIFY_VERSION}/tests \
  && mv websockify-${WEBSOCKIFY_VERSION} /opt/bin/noVNC/utils/websockify

RUN env HTTPS_PROXY=http://home.alot.pw:18888 curl -skL https://github.com/fatedier/frp/releases/download/v0.47.0/frp_0.47.0_linux_amd64.tar.gz | gunzip |tar xvf - -C /opt && sh -c '/bin/rm -rf /opt/frp_0.47.0_linux_amd64/{frps*,*.ini}'

# FROM joyzoursky/python-chromedriver:3.9-alpine-selenium
FROM python:3.10-alpine
LABEL org.opencontainers.image.authors="yong.li@governance-solutions.com"
ENV PATH /opt/node-v16.19.1-linux-x64/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/frp_0.47.0_linux_amd64

ENV SCREEN_WIDTH=1280 \
    SCREEN_HEIGHT=720 \
    SCREEN_DEPTH=16 \
    DISPLAY=:99 \
    PYTHONWARNINGS=ignore \
    WEBKIT_DEPS="" \
    FIREFOX_DEPS="" \
    CHROMIUM_DEPS="chromium chromium-chromedriver" \
    TEST_DEPS="python3" \
    FLOW_DEPS="jq curl unzip jwm tzdata xvfb font-noto-cjk x11vnc xz openssh-server xterm iproute2 git" \
    REC_DEPS="ffmpeg screen pulseaudio" \
    PYTHON_DEPS="py3-pandas bash aha"
#   SERVER_DEPS="openjdk-8-jdk redis-server mysql-server nginx maven"
# RUN sed -i -E 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list && sed -i -E 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list
EXPOSE 5900 7900
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.15/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.15/community" >> /etc/apk/repositories && \
    apk update && \
    apk add  $FLOW_DEPS $REC_DEPS $PYTHON_DEPS $CHROMIUM_DEPS && \
  sed -i 's/BIG-REQUESTS/_IG-REQUESTS/' /usr/lib/libxcb.so.1
# RUN curl -skL https://mirrors.tuna.tsinghua.edu.cn/nodejs-release/v16.9.1/node-v16.9.1-linux-x64.tar.xz|unxz|tar xvf -  -C /opt
# RUN curl -skL https://nodejs.org/download/release/v16.19.1/node-v16.19.1-linux-x64.tar.xz|unxz|tar xvf -  -C /opt
# RUN curl -skL https://mirrors.aliyun.com/nodejs-release/v16.19.1/node-v16.19.1-linux-x64.tar.xz|unxz|tar xvf -  -C /opt

#-i https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip install --upgrade pip && \
    pip install --no-cache-dir \
                    requests selenium && \
    pip freeze &&\
    ssh-keygen -A &&\
    echo root:password|chpasswd
COPY robotframework-browser/base/sshd_config /etc/ssh/sshd_config

#==============================
# Generating the VNC password as seluser
# So the service can be started with seluser
#==============================

RUN mkdir -p ${HOME}/.vnc \
  && x11vnc -storepasswd secret ${HOME}/.vnc/passwd

RUN chmod -R 777 ${HOME} \
  && chgrp -R 0 ${HOME} \
  && chmod -R g=u ${HOME}

COPY --from=downloader /opt/ /opt

ENV  TZ=Asia/Shanghai
COPY .step/*.sh robotframework-browser/ignored-envs.txt robotframework-browser/*.py robotframework-browser/*.sh /root/
COPY python-chromedriver/step.sh /root/
RUN chmod +x /root/*.sh /root/*.py 
EXPOSE 5900 7900
ENTRYPOINT [ "/root/entry.sh"]