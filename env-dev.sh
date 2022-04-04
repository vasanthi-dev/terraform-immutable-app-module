#!/bin/bash

if [ -d /home/roboshop ]; then
  COMPONENT=$(ls -1 /home/roboshop/)
  if [ -f /etc/systemd/system/${COMPONENT}.service ]; then
    sed -i -e 's/ENV/dev/' /etc/systemd/system/${COMPONENT}.service /etc/filebeat/filebeat.yml
    set-hostname -skip-apply ${COMPONENT}-dev
    systemctl daemon-reload
    systemctl enable ${COMPONENT}
    systemctl restart ${COMPONENT}
  fi
fi

if [ -f /etc/nginx/default.d/roboshop.conf ]; then
  sed -i -e 's/ENV/dev/' /etc/nginx/default.d/roboshop.conf /etc/filebeat/filebeat.yml
  set-hostname -skip-apply frontend-dev
  systemctl restart nginx
fi