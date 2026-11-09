FROM docker.io/sbx/shell-docker-image:latest

USER root

RUN npm install -g --ignore-scripts \
    @earendil-works/pi-coding-agent@1.5.0

ENV OPENAI_API_KEY=proxy-managed

USER agent

WORKDIR /home/agent/workspace

ENTRYPOINT ["pi"]
CMD []
