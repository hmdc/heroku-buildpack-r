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

mv /app/.root/usr/bin/pandoc /app/.root/usr/bin/pandoc.new
cat<<EOF > /app/.root/usr/bin/pandoc
#!/bin/bash
echo "\$@" >> /tmp/pandoc.log
ls -all /tmp/R >> /tmp/pandoc.log
/usr/bin/pandoc.new "\$@" | tee -a /tmp/pandoc.log
EOF
chmod a+x /app/.root/usr/bin/pandoc

COMMAND="${@:$n}"
echo "Launching ${COMMAND}..."
eval "${COMMAND}" &

echo "Launching apache"
exec /app/apache/sbin/httpd -DFOREGROUND -DNO_DETACH
