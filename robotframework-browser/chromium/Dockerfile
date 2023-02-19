# docker build -t registry.cn-beijing.aliyuncs.com/windli/robotframework-browser-chromium:1.0 -f Dockerfile ..
FROM registry.cn-beijing.aliyuncs.com/windli/robotframework-browser:1.0
LABEL org.opencontainers.image.authors="yong.li@governance-solutions.com"

RUN rfbrowser init && bash -c 'rm -rf /usr/local/lib/python3*/dist-packages/Browser/wrapper/node_modules/playwright-core/.local-browsers/{firefox*,webkit*}'
RUN ln -s /usr/local/lib/python3*/*-packages/Browser/wrapper/node_modules/playwright-core/.local-browsers/ /opt/browsers

EXPOSE 5900
EXPOSE 7900
ENTRYPOINT [ "/root/entry.sh"]
