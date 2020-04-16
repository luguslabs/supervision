# Base image
FROM grafana/grafana

# Set user
USER root

# Install GO
RUN apk add --no-cache git make musl-dev go supervisor curl jq

# Install Prometheus
RUN go get github.com/prometheus/prometheus/cmd/prometheus/...

# Creating app and adding files
RUN mkdir /app
RUN mkdir /prometheus
RUN mkdir /dashboards

# Copy files
COPY supervisord.conf /etc/supervisord/supervisord.conf
COPY start-grafana.sh /app
COPY start-prometheus.sh /app
COPY prometheus.yml /etc/prometheus/prometheus.yml
COPY dashboards/* /dashboards

WORKDIR /app

EXPOSE 3000

ENTRYPOINT ["supervisord","-c","/etc/supervisord/supervisord.conf"]
