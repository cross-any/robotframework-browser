# docker build -t registry.cn-beijing.aliyuncs.com/windli/robotframework-browser-all:1.0 -f Dockerfile ..
FROM registry.cn-beijing.aliyuncs.com/windli/robotframework-browser-all-base:1.0
LABEL org.opencontainers.image.authors="yong.li@governance-solutions.com"

COPY *.sh *.py ignored-envs.txt /root/

RUN chmod +x /root/*.sh /root/*.py
ENTRYPOINT [ "/root/entry_point.sh"]