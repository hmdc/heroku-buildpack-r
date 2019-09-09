#!/usr/bin/env bash
for var in `env|cut -f1 -d=`; do
  echo "PassEnv $var" >> /app/apache/etc/apache2/httpd.conf;
done

n=1

mkdir -p /app/apache/logs
mkdir -p /app/apache/var/cache
touch /app/apache/logs/error_log
touch /app/apache/logs/access_log
mv /app/.root/usr/bin/pandoc /app/.root/usr/bin/pandoc.new
cat<<EOF > /app/.root/usr/bin/pandoc
#!/bin/bash
ARGS_RELATIVE=\$(echo "\$@"|sed -e 's/\/app\///g;s/\/tmp/\/app\/.root\/tmp/g')
echo "==Old Args==" >> /tmp/pandoc.log
echo "\$@" >> /tmp/pandoc.log
echo "==New Args==" >> /tmp/pandoc.log
echo "\$ARGS_RELATIVE" >> /tmp/pandoc.log
echo "==Files==" >> /tmp/pandoc.log
ls -alR /tmp >> /tmp/pandoc.log
echo "==CURRENT=="
pwd >> /tmp/pandoc.log
/usr/bin/pandoc.new \$ARGS_RELATIVE | tee -a /tmp/pandoc.log
EOF
chmod a+x /app/.root/usr/bin/pandoc

COMMAND="${@:$n}"
echo "Launching ${COMMAND}..."
eval "${COMMAND}" &

echo "Launching apache"
exec /app/apache/sbin/httpd -DFOREGROUND -DNO_DETACH
