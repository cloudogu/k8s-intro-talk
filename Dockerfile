FROM cloudogu/reveal.js:3.9.2-r8 as base

FROM base as aggregator
ENV TITLE='Plunging-Into-Kubernetes-An-Introduction' 
ENV THEME_CSS='css/cloudogu-black.css'
USER root
# Remove demo slides before templating
RUN rm -rf  /reveal/docs
COPY . /reveal
RUN mv /reveal/resources/ /
RUN /scripts/templateIndexHtml

FROM base
ENV SKIP_TEMPLATING='true'
COPY --from=aggregator --chown=nginx /reveal /reveal