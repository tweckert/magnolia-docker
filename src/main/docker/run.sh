#!/bin/bash

set -e
set -m

echo "adjusting setenv.sh with custom env. variables..."
cat << EOF > /opt/tomcat/bin/setenv.sh
#!/bin/sh
JAVA_OPTS="$JAVA_OPTS -Xdebug -Xrunjdwp:transport=dt_socket,address=9090,server=y,suspend=n"
JAVA_OPTS="$JAVA_OPTS -Xms${HEAP_SIZE} -Xmx${HEAP_SIZE}"
JAVA_OPTS="$JAVA_OPTS -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -verbose:gc -Xloggc:/opt/tomcat/temp/gc.log"
JAVA_OPTS="$JAVA_OPTS -Djava.security.egd=file:/dev/./urandom"
export JAVA_OPTS
EOF

# copy the Magnolia webapp bundle into Tomcat, unless they already exist
if [ "${AUTHOR}" == "true" ]; then
  echo "Start AUTHOR instance"
  if [ ! -f /opt/tomcat/webapps/magnoliaAuthor.war ]; then
    cp /usr/share/mgnl/magnolia.war /opt/tomcat/webapps/magnoliaAuthor.war
  fi
fi
if [ "${PUBLIC}" == "true" ]; then
  echo "Start PUBLIC instance"
  if [ ! -f /opt/tomcat/webapps/ROOT.war ]; then
    cp /usr/share/mgnl/magnolia.war /opt/tomcat/webapps/magnoliaPublic.war
  fi
fi

echo "=> Starting Magnolia webapp..."
exec /opt/tomcat/bin/catalina.sh run &
fg