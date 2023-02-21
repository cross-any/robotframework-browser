# docker build -t registry.cn-beijing.aliyuncs.com/windli/robotframework-browser-flow-chromium:1.0 -f Dockerfile ..
FROM registry.cn-beijing.aliyuncs.com/windli/robotframework-browser-chromium:1.0
LABEL org.opencontainers.image.authors="yong.li@governance-solutions.com"
ENV  TZ=Asia/Shanghai
COPY .step/*.sh robotframework-browser/ignored-envs.txt robotframework-browser/*.py robotframework-browser/*.sh flow-base/step.sh /root/
RUN chmod +x /root/*.sh /root/*.py 
EXPOSE 5900 7900
ENTRYPOINT [ "/root/entry.sh"]
