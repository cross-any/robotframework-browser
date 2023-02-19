# docker build -t registry.cn-beijing.aliyuncs.com/windli/robotframework-browser-all:1.0 -f Dockerfile ..
# FROM registry.cn-beijing.aliyuncs.com/rdc-builds/base:1.0
FROM registry.cn-beijing.aliyuncs.com/windli/robotframework-browser:1.0
LABEL org.opencontainers.image.authors="yong.li@governance-solutions.com"

RUN rfbrowser init
RUN ln -s /usr/local/lib/python3*/dist-packages/Browser/wrapper/node_modules/playwright-core/.local-browsers/ /opt/browsers && \
    mkdir -p /root/.cache && \
    ln -s /usr/local/lib/python3*/*-packages/Browser/wrapper/node_modules/playwright-core/.local-browsers/ /root/.cache/ms-playwright && \
    ln -s /usr/local/lib/python3*/*-packages/Browser/wrapper/node_modules/.bin/playwright /usr/bin/

EXPOSE 5900
EXPOSE 7900
ENTRYPOINT [ "/root/entry.sh"]
