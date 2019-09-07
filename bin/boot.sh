#!/usr/bin/env bash
for var in `env|cut -f1 -d=`; do
  echo "PassEnv $var" >> /app/apache/etc/apache2/httpd.conf;
done

n=1

mkdir -p /app/apache/logs
mkdir -p /app/apache/var/cache
touch /app/apache/logs/error_log
touch /app/apache/logs/access_log
mkdir -v /app/.root/tmp/R
ln -sfv /app/.root/tmp/R /tmp/R
ln -sfv /app/.root/app/packrat/lib /app/packrat/lib

mv /app/.root/bin/pandoc /app/.root/bin/pandoc.new
cat<<EOF > /app/.root/bin/pandoc
#!/bin/bash
echo "$@" >> /tmp/pandoc.log
exec /usr/bin/pandoc "$@"
EOF

COMMAND="${@:$n}"
echo "Launching ${COMMAND}..."
eval "${COMMAND}" &

echo "Launching apache"
exec /app/apache/sbin/httpd -DFOREGROUND -DNO_DETACH
