FROM docker/sandbox-templates:shell

USER root

RUN npm install -g --ignore-scripts \
    @earendil-works/pi-coding-agent@1.5.0

ENV OPENAI_API_KEY=proxy-managed

USER agent

WORKDIR /home/agent/workspace

ENTRYPOINT ["pi"]
CMD []