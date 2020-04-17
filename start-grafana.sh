#!/bin/bash

if [ -z "$GF_SECURITY_ADMIN_PASSWORD" ]; then
  echo "Please set GF_SECURITY_ADMIN_PASSWORD..."
  exit 1
fi

if [ -z "$GF_SERVER_HTTP_PORT" ]; then
  GF_SERVER_HTTP_PORT=3000
fi

echo 'Starting Grafana...'
/run.sh "$@" &

sleep 10


echo "***************"
ls /dashboards
echo "***************"

firstDashId="null"

AddDataSource() {
  curl -H "Content-Type: application/json" \
   -X POST -d "{\"name\":\"Prometheus\", 
                \"type\":\"prometheus\", 
          \"url\":\"http://localhost:9090\",
          \"access\":\"proxy\",
          \"basicAuth\":false}" \
   http://admin:$GF_SECURITY_ADMIN_PASSWORD@localhost:$GF_SERVER_HTTP_PORT/api/datasources
}

AddDashboard() {
  curl -s -H "Content-Type: application/json" \
         -X POST -d "`cat $1`" \
  http://admin:$GF_SECURITY_ADMIN_PASSWORD@localhost:$GF_SERVER_HTTP_PORT/api/dashboards/db
}

AddDashBoards(){
  for filename in /dashboards/*.json; do
    addDash=$(AddDashboard "$filename")
    echo $addDash
    if [ "$firstDashId" == "null" ]; then
      firstDashId=$(echo $addDash | jq -r '.id')
      echo "First Dashboard ID is: $firstDashId"
    fi
  done
}

SetHomeDashboard() {
    curl -s -H "Content-Type: application/json" \
         -X PUT -d "{\"theme\": \"\",
                     \"homeDashboardId\":$1,
                     \"timezone\":\"utc\"}" \
    http://admin:$GF_SECURITY_ADMIN_PASSWORD@localhost:$GF_SERVER_HTTP_PORT/api/org/preferences
}

until AddDataSource; do
  echo 'Configuring Data Sources in Grafana...'
  sleep 1
done

until AddDashBoards; do
  echo 'Configuring Dashboards in Grafana...'
  sleep 1
done

if [ "$firstDashId" != "null" ]; then
  until SetHomeDashboard "$firstDashId"; do
    echo "Setting home dashboard to first added..."
    sleep 1
  done
fi

echo "Grafana has been configured"

wait
