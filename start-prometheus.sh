#!/bin/bash
if [ -z "$PROMETHEUS_TARGET" ]; then
    echo "Please set PROMETHEUS_TARGET variable..."
    exit 1
fi

sed -i "s/<TARGET>/$PROMETHEUS_TARGET/g" /etc/prometheus/prometheus.yml

echo "Starting prometheus..."

/root/go/bin/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/prometheus
 