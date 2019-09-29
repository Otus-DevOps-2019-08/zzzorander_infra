#!/bin/sh

cat > /etc/systemd/system/puma.service <<EOF
[Unit]
Description=Puma HTTP Server
After=network.target
[Service]
Type=simple
WorkingDirectory=/home/appuser/reddit
ExecStart=/usr/local/bin/puma
Restart=always
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable puma
systemctl start puma
