FROM docker.io/fedora
MAINTAINER mrunge

LABEL RUN='podman run -d -p 9099:9099 $IMAGE'
USER root

RUN dnf -y update
RUN dnf -y install golang && dnf clean all
RUN go get github.com/chrusty/prometheus_webhook_snmptrapper
RUN go build github.com/chrusty/prometheus_webhook_snmptrapper

ENV SNMP_COMMUNITY="public"
ENV SNMP_RETRIES=1
ENV SNMP_TRAP_ADDRESS="localhost:162"
ENV WEBHOOK_ADDRESS="0.0.0.0:9099"

EXPOSE 9099

RUN mv /prometheus_webhook_snmptrapper /usr/local/bin/prometheus_webhook_snmptrapper
COPY sample-alert.json /

CMD exec /usr/local/bin/prometheus_webhook_snmptrapper -snmpcommunity=$SNMP_COMMUNITY -snmpretries=$SNMP_RETRIES -snmptrapaddress=$SNMP_TRAP_ADDRESS -webhookaddress=$WEBHOOK_ADDRESS

# buildah build-using-dockerfile -t "mrunge/prometheus-webhook-snmptrapper" .
