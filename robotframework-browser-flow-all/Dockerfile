# docker build -t registry.cn-beijing.aliyuncs.com/windli/flow-robotframework-selenium2:1.0 -f Dockerfile ..
# FROM registry.cn-beijing.aliyuncs.com/rdc-builds/base:1.0
FROM registry.cn-beijing.aliyuncs.com/windli/robotframework-browser-all:1.0
LABEL org.opencontainers.image.authors="yong.li@governance-solutions.com"

COPY robotframework-browser*/step.sh /root/step.sh
COPY robotframework-browser/*.sh /root/
RUN chmod +x /root/*.sh /root/*.py /usr/bin/jq
COPY ignored-envs.txt /ignored-envs.txt

EXPOSE 5900
EXPOSE 7900
ENTRYPOINT [ "/root/entry.sh"]
