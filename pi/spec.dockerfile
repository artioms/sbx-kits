FROM docker.io/sbx/shell-docker-image:latest

USER root

RUN npm install -g --ignore-scripts \
    @earendil-works/pi-coding-agent@latest

ENV OPENAI_API_KEY=proxy-managed

USER agent

WORKDIR /home/agent/workspace

ENTRYPOINT ["pi"]
CMD []
